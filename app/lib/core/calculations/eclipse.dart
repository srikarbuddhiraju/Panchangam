import 'julian_day.dart';
import 'lunar_position.dart';
import 'tithi.dart';

/// Eclipse detection and data model.
///
/// Algorithm: Scan each Amavasya (solar eclipse candidate) and Purnima
/// (lunar eclipse candidate) in a year, check if Moon is within the
/// eclipse limit (~15° for lunar, ~18° for solar) of a lunar node.
class Eclipse {
  Eclipse._();

  /// Approximate longitude of Rahu (North Node) for a given JD.
  /// Rahu moves retrograde at ~19.3° per year (full cycle ~18.6 years).
  static double rahuLongitude(double jd) {
    // At J2000.0 (JD 2451545.0), Rahu ≈ 12° (Meeus approximation)
    // Rate: -0.052953922 degrees/day (retrograde)
    final double lon =
        JulianDay.normalize360(12.0 - 0.052953922 * (jd - JulianDay.j2000));
    return lon;
  }

  /// Ketu (South Node) = Rahu + 180°.
  static double ketuLongitude(double jd) {
    return JulianDay.normalize360(rahuLongitude(jd) + 180.0);
  }

  /// Find all eclipses in a given Gregorian year.
  static List<EclipseData> findInYear(int year) {
    final List<EclipseData> eclipses = [];

    // Scan every day of the year
    final DateTime start = DateTime.utc(year, 1, 1);
    final DateTime end = DateTime.utc(year, 12, 31);

    DateTime current = start;
    while (current.isBefore(end)) {
      final double jd = JulianDay.fromDateTime(
        current.year, current.month, current.day, 12, 0, 0,
      );

      final double diff = Tithi.moonSunDiff(jd);

      // Amavasya window (Moon-Sun diff ≈ 0°, wrapping)
      if (diff >= 354 || diff < 6) {
        final EclipseData? e = _checkSolarEclipse(jd, current);
        if (e != null) eclipses.add(e);
      }

      // Purnima window (Moon-Sun diff ≈ 180°)
      if (diff >= 174 && diff < 186) {
        final EclipseData? e = _checkLunarEclipse(jd, current);
        if (e != null) eclipses.add(e);
      }

      current = current.add(const Duration(days: 1));
    }

    // Deduplicate (may detect same eclipse on adjacent days)
    return _deduplicate(eclipses);
  }

  static EclipseData? _checkSolarEclipse(double jd, DateTime date) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);

    final double distRahu = _angularDistance(moonLon, rahu);
    final double distKetu = _angularDistance(moonLon, ketu);

    const double solarEclipseLimit = 18.0; // degrees

    if (distRahu <= solarEclipseLimit || distKetu <= solarEclipseLimit) {
      final bool nearRahu = distRahu < distKetu;
      final double nodeDist = nearRahu ? distRahu : distKetu;
      final EclipseType type = nodeDist < 10
          ? EclipseType.solarTotal
          : EclipseType.solarAnnular;

      return EclipseData(
        date: date,
        type: type,
        sutakStart: date.subtract(const Duration(hours: 12)),
        isVisibleInIndia: _isSolarVisibleInIndia(jd),
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

    const double lunarEclipseLimit = 12.0; // degrees

    if (distRahu <= lunarEclipseLimit || distKetu <= lunarEclipseLimit) {
      final double nodeDist =
          distRahu < distKetu ? distRahu : distKetu;
      final EclipseType type = nodeDist < 4
          ? EclipseType.lunarTotal
          : EclipseType.lunarPartial;

      return EclipseData(
        date: date,
        type: type,
        sutakStart: date.subtract(const Duration(hours: 9)),
        isVisibleInIndia: true, // Lunar eclipses visible from entire night side
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

  /// Very rough India visibility check for solar eclipses.
  /// A proper check requires computing the eclipse shadow path.
  static bool _isSolarVisibleInIndia(double jd) {
    // Simplified: India is at roughly 20°N, 78°E
    // Check if it's daytime in India when the eclipse peak occurs
    return true; // Conservative: show all solar eclipses
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

  bool get isSolar => this == EclipseType.solarTotal ||
      this == EclipseType.solarAnnular ||
      this == EclipseType.solarPartial;
}

class EclipseData {
  final DateTime date;
  final EclipseType type;
  final DateTime sutakStart;
  final bool isVisibleInIndia;
  final double moonSunDiff;
  final double nodeDistance;

  const EclipseData({
    required this.date,
    required this.type,
    required this.sutakStart,
    required this.isVisibleInIndia,
    required this.moonSunDiff,
    required this.nodeDistance,
  });
}
