import 'dart:math' as math;
import 'julian_day.dart';
import 'lunar_position.dart';
import 'tithi.dart';
import 'ayanamsa.dart';

/// Eclipse detection and data model.
///
/// Algorithm: Scan each Amavasya (solar eclipse candidate) and Purnima
/// (lunar eclipse candidate) in a year, check if Moon is within the
/// eclipse limit of a lunar node.
///
/// Sutak is calculated from the actual Sparsha (first umbral contact) time,
/// not from the calendar date.
class Eclipse {
  Eclipse._();

  /// Sidereal longitude of Rahu (North Node) for a given JD.
  /// Formula: Meeus, Astronomical Algorithms Ch.47 (mean ascending node).
  /// Tropical Ω = 125.0445479 − 0.052953915°/day from J2000.
  /// Converted to sidereal because our Moon longitude is sidereal.
  static double rahuLongitude(double jd) {
    final double tropicalRahu = JulianDay.normalize360(
      125.0445479 - 0.052953915 * (jd - JulianDay.j2000),
    );
    return Ayanamsa.toSidereal(tropicalRahu, jd);
  }

  /// Ketu (South Node) = Rahu + 180°.
  static double ketuLongitude(double jd) {
    return JulianDay.normalize360(rahuLongitude(jd) + 180.0);
  }

  /// Node distance for a given JD (minimum of distRahu and distKetu).
  static double _nodeDist(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);
    return math.min(_angularDistance(moonLon, rahu), _angularDistance(moonLon, ketu));
  }

  /// Find all eclipses in a given Gregorian year.
  static List<EclipseData> findInYear(int year) {
    final List<EclipseData> eclipses = [];

    final DateTime start = DateTime.utc(year, 1, 1);
    final DateTime end = DateTime.utc(year, 12, 31);

    DateTime current = start;
    while (current.isBefore(end)) {
      final double jd = JulianDay.fromDateTime(
        current.year, current.month, current.day, 12, 0, 0,
      );

      final double diff = Tithi.moonSunDiff(jd);

      // Amavasya window (solar eclipse candidate)
      if (diff >= 354 || diff < 6) {
        final EclipseData? e = _checkSolarEclipse(jd, current);
        if (e != null) eclipses.add(e);
      }

      // Purnima window (lunar eclipse candidate)
      if (diff >= 174 && diff < 186) {
        final EclipseData? e = _checkLunarEclipse(jd, current);
        if (e != null) eclipses.add(e);
      }

      current = current.add(const Duration(days: 1));
    }

    return _deduplicate(eclipses);
  }

  // ── Sparsha / Moksha helpers ───────────────────────────────────────────────

  /// Find the JD of minimum node distance (eclipse maximum) by scanning
  /// hourly over ±30 hours around the candidate date's noon.
  static double _findMaximumJD(DateTime date) {
    double minDist = double.infinity;
    double maxJD = JulianDay.fromDateTime(
        date.year, date.month, date.day, 12, 0, 0);

    for (int h = -30; h <= 30; h++) {
      final DateTime dt = DateTime.utc(
              date.year, date.month, date.day, 12)
          .add(Duration(hours: h));
      final double jd = JulianDay.fromDateTime(
          dt.year, dt.month, dt.day, dt.hour, 0, 0);
      final double dist = _nodeDist(jd);
      if (dist < minDist) {
        minDist = dist;
        maxJD = jd;
      }
    }
    return maxJD;
  }

  /// Scan backward from eclipse maximum at 5-min steps to find Sparsha
  /// (when node distance first drops below [threshold]).
  static DateTime _findSparsha(double maxJD, double threshold) {
    // At maxJD, dist < threshold. Go backward until dist >= threshold.
    for (int m = 5; m <= 1440; m += 5) {
      final double jd = maxJD - m / 1440.0;
      if (_nodeDist(jd) >= threshold) {
        // Crossed threshold between (jd) and (jd + 5min)
        return JulianDay.toIST(jd + 5.0 / 1440.0);
      }
    }
    return JulianDay.toIST(maxJD - 6.0 / 24.0); // fallback: 6h before max
  }

  /// Scan forward from eclipse maximum at 5-min steps to find Moksha
  /// (when node distance rises back above [threshold]).
  static DateTime _findMoksha(double maxJD, double threshold) {
    for (int m = 5; m <= 1440; m += 5) {
      final double jd = maxJD + m / 1440.0;
      if (_nodeDist(jd) >= threshold) {
        return JulianDay.toIST(jd - 5.0 / 1440.0);
      }
    }
    return JulianDay.toIST(maxJD + 6.0 / 24.0); // fallback: 6h after max
  }

  // ── Eclipse checkers ───────────────────────────────────────────────────────

  static EclipseData? _checkSolarEclipse(double jd, DateTime date) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);
    final double distRahu = _angularDistance(moonLon, rahu);
    final double distKetu = _angularDistance(moonLon, ketu);

    const double solarEclipseLimit = 17.0;

    if (distRahu <= solarEclipseLimit || distKetu <= solarEclipseLimit) {
      final double nodeDist = distRahu < distKetu ? distRahu : distKetu;
      final EclipseType type = nodeDist < 9
          ? EclipseType.solarTotal
          : nodeDist < 14
              ? EclipseType.solarAnnular
              : EclipseType.solarPartial;

      // Compute actual contact times
      final double maxJD = _findMaximumJD(date);
      final DateTime sparsha = _findSparsha(maxJD, solarEclipseLimit);
      final DateTime moksha = _findMoksha(maxJD, solarEclipseLimit);

      return EclipseData(
        date: date,
        type: type,
        sparsha: sparsha,
        moksha: moksha,
        sutakStart: sparsha.subtract(const Duration(hours: 12)),
        sutakStartVulnerable: sparsha.subtract(const Duration(hours: 4)),
        isVisibleInIndia: true,
        moonSunDiff: Tithi.moonSunDiff(jd),
        nodeDistance: nodeDist,
      );
    }
    return null;
  }

  static EclipseData? _checkLunarEclipse(double jd, DateTime date) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);
    final double distRahu = _angularDistance(moonLon, rahu);
    final double distKetu = _angularDistance(moonLon, ketu);

    const double lunarEclipseLimit = 12.0;
    // Umbral threshold (below this = partial or total, not just penumbral)
    const double umbralThreshold = 9.5;

    if (distRahu <= lunarEclipseLimit || distKetu <= lunarEclipseLimit) {
      final double nodeDist = distRahu < distKetu ? distRahu : distKetu;

      // Calibrated against NASA 2025-2026 eclipse data
      final EclipseType type = nodeDist < 7
          ? EclipseType.lunarTotal
          : nodeDist < 9.5
              ? EclipseType.lunarPartial
              : EclipseType.lunarPenumbral;

      // Compute actual umbral contact times (used for sutak)
      final double maxJD = _findMaximumJD(date);
      final double sutakThreshold =
          nodeDist < umbralThreshold ? umbralThreshold : lunarEclipseLimit;

      final DateTime sparsha = _findSparsha(maxJD, sutakThreshold);
      final DateTime moksha = _findMoksha(maxJD, sutakThreshold);

      return EclipseData(
        date: date,
        type: type,
        sparsha: sparsha,
        moksha: moksha,
        sutakStart: sparsha.subtract(const Duration(hours: 9)),
        sutakStartVulnerable: sparsha.subtract(const Duration(hours: 3)),
        isVisibleInIndia: true,
        moonSunDiff: Tithi.moonSunDiff(jd),
        nodeDistance: nodeDist,
      );
    }
    return null;
  }

  static double _angularDistance(double lon1, double lon2) {
    double d = (lon1 - lon2).abs();
    if (d > 180) d = 360 - d;
    return d;
  }

  static List<EclipseData> _deduplicate(List<EclipseData> raw) {
    final List<EclipseData> result = [];
    for (final e in raw) {
      if (result.isEmpty ||
          e.date.difference(result.last.date).inDays.abs() > 5) {
        result.add(e);
      }
    }
    return result;
  }
}

// ── Enums & data model ────────────────────────────────────────────────────────

enum EclipseType {
  solarTotal,
  solarAnnular,
  solarPartial,
  lunarTotal,
  lunarPartial,
  lunarPenumbral,
}

extension EclipseTypeLabel on EclipseType {
  String get nameTe {
    switch (this) {
      case EclipseType.solarTotal:
        return 'పూర్ణ సూర్య గ్రహణం';
      case EclipseType.solarAnnular:
        return 'కంకణ సూర్య గ్రహణం';
      case EclipseType.solarPartial:
        return 'పాక్షిక సూర్య గ్రహణం';
      case EclipseType.lunarTotal:
        return 'పూర్ణ చంద్ర గ్రహణం';
      case EclipseType.lunarPartial:
        return 'పాక్షిక చంద్ర గ్రహణం';
      case EclipseType.lunarPenumbral:
        return 'ఉపచ్ఛాయ చంద్ర గ్రహణం';
    }
  }

  String get nameEn {
    switch (this) {
      case EclipseType.solarTotal:
        return 'Total Solar Eclipse';
      case EclipseType.solarAnnular:
        return 'Annular Solar Eclipse';
      case EclipseType.solarPartial:
        return 'Partial Solar Eclipse';
      case EclipseType.lunarTotal:
        return 'Total Lunar Eclipse';
      case EclipseType.lunarPartial:
        return 'Partial Lunar Eclipse';
      case EclipseType.lunarPenumbral:
        return 'Penumbral Lunar Eclipse';
    }
  }

  bool get isSolar =>
      this == EclipseType.solarTotal ||
      this == EclipseType.solarAnnular ||
      this == EclipseType.solarPartial;
}

class EclipseData {
  final DateTime date;
  final EclipseType type;

  /// First umbral contact (IST).
  final DateTime sparsha;

  /// Last umbral contact (IST).
  final DateTime moksha;

  /// General sutak start = sparsha − 9h (lunar) or − 12h (solar).
  final DateTime sutakStart;

  /// Sutak for elderly, children, and sick = sparsha − 3h (lunar) or − 4h (solar).
  final DateTime sutakStartVulnerable;

  final bool isVisibleInIndia;
  final double moonSunDiff;
  final double nodeDistance;

  const EclipseData({
    required this.date,
    required this.type,
    required this.sparsha,
    required this.moksha,
    required this.sutakStart,
    required this.sutakStartVulnerable,
    required this.isVisibleInIndia,
    required this.moonSunDiff,
    required this.nodeDistance,
  });
}
