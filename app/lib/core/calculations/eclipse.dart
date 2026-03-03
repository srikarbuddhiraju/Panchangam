import 'dart:math' as math;
import 'julian_day.dart';
import 'lunar_position.dart';
import 'tithi.dart';
import 'ayanamsa.dart';

/// Eclipse detection and timing.
///
/// Detection: scan each Amavasya/Purnima; check if Moon is within the
/// eclipse limit of a lunar node (rough pre-filter).
///
/// Timing (Sparsha/Moksha): use actual shadow geometry — Moon's distance
/// from the centre of Earth's umbral shadow, accounting for Moon's
/// ecliptic latitude. This replaces the old "node-distance threshold"
/// approach that was giving contact times off by many hours.
///
/// Shadow constants (mean distances; ±2% over the year):
///   Umbral radius at Moon's mean distance  = 0.7275°
///   Penumbral radius at Moon's mean distance = 1.2686°
///   Moon's apparent radius                 = 0.2725°
///
/// For lunar eclipses:
///   Umbral first/last contact  : miss < umbral + moon = 1.0000°
///   Total first/last contact   : miss < umbral − moon = 0.4550°
///   Penumbral first/last contact: miss < penumbral + moon = 1.5411°
class Eclipse {
  Eclipse._();

  // ── Shadow geometry constants ─────────────────────────────────────────────

  static const double _umbralR     = 0.7275;  // Earth umbral shadow radius (°)
  static const double _penumbralR  = 1.2686;  // Earth penumbral shadow radius (°)
  static const double _moonR       = 0.2725;  // Moon apparent radius (°)

  static const double _umbralContact     = _umbralR + _moonR;   // 1.0000° — partial begins/ends
  static const double _totalContact      = _umbralR - _moonR;   // 0.4550° — total begins/ends
  static const double _penumbralContact  = _penumbralR + _moonR; // 1.5411° — penumbral begins/ends

  static const double _sunR         = 0.2650;                   // Sun apparent radius (°, mean)
  // Geocentric partial contact limit for any observer on Earth.
  // Accounts for sunR + moonR + lunar horizontal parallax (≈0.95°).
  // Meeus Ch.54 empirical solar ecliptic limit: 1.566°.
  static const double _solarContact = 1.566;

  // ── Node longitude (kept for detection pre-filter) ────────────────────────

  /// Sidereal longitude of Rahu (North Node) for a given JD.
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

  /// Longitude distance Moon→nearest node (pre-filter only, not used for timing).
  static double _nodeDist(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);
    return math.min(_angularDistance(moonLon, rahu), _angularDistance(moonLon, ketu));
  }

  // ── Shadow miss-distance ──────────────────────────────────────────────────

  /// Angular distance (°) between Moon's centre and Earth's shadow centre.
  ///
  /// shadow_centre = anti-solar point = Sun's longitude + 180°
  /// delta_lon     = Moon − shadow_centre = (Moon − Sun) − 180° = moonSunDiff − 180°
  /// miss          = √(delta_lon² + beta²)   where beta = Moon's ecliptic latitude
  static double _shadowMiss(double jd) {
    double delta = Tithi.moonSunDiff(jd) - 180.0;
    // Normalise to (−180, 180]
    delta = ((delta + 180.0) % 360.0) - 180.0;
    final double beta = LunarPosition.latitude(jd);
    return math.sqrt(delta * delta + beta * beta);
  }

  /// Angular distance (°) between Moon's centre and Sun's centre.
  ///
  /// At new moon moonSunDiff ≈ 0° (or 360°).  Normalise to (−180, 180] so
  /// the value stays near 0° regardless of the 0/360 wrap.
  /// miss = √(delta_lon² + beta²)   where beta = Moon's ecliptic latitude
  static double _solarMiss(double jd) {
    double delta = Tithi.moonSunDiff(jd);
    // Normalise to (−180, 180]
    delta = ((delta + 180.0) % 360.0) - 180.0;
    final double beta = LunarPosition.latitude(jd);
    return math.sqrt(delta * delta + beta * beta);
  }

  // ── Eclipse maximum (minimum miss-distance) ───────────────────────────────

  /// Find the JD of minimum shadow miss-distance (= eclipse maximum).
  /// Two-pass: hourly over ±36 h to bracket peak, then 1-min refinement.
  static double _findLunarMaximumJD(DateTime date) {
    // Pass 1 — hourly
    double minMiss = double.infinity;
    double roughJD = JulianDay.fromDateTime(
        date.year, date.month, date.day, 12, 0, 0);

    for (int h = -36; h <= 36; h++) {
      final DateTime dt =
          DateTime.utc(date.year, date.month, date.day, 12)
              .add(Duration(hours: h));
      final double jd = JulianDay.fromDateTime(
          dt.year, dt.month, dt.day, dt.hour, 0, 0);
      final double miss = _shadowMiss(jd);
      if (miss < minMiss) {
        minMiss = miss;
        roughJD = jd;
      }
    }

    // Pass 2 — 1-min steps over ±60 min around rough peak
    double fineJD = roughJD;
    double fineMiss = minMiss;
    for (int m = -60; m <= 60; m++) {
      final double jd = roughJD + m / 1440.0;
      final double miss = _shadowMiss(jd);
      if (miss < fineMiss) {
        fineMiss = miss;
        fineJD = jd;
      }
    }
    return fineJD;
  }

  /// Find the JD of minimum Moon–Sun angular separation (= solar eclipse maximum).
  /// Two-pass: hourly over ±36 h to bracket peak, then 1-min refinement.
  static double _findSolarMaximumJD(DateTime date) {
    // Pass 1 — hourly
    double minMiss = double.infinity;
    double roughJD = JulianDay.fromDateTime(
        date.year, date.month, date.day, 12, 0, 0);

    for (int h = -36; h <= 36; h++) {
      final DateTime dt =
          DateTime.utc(date.year, date.month, date.day, 12)
              .add(Duration(hours: h));
      final double jd = JulianDay.fromDateTime(
          dt.year, dt.month, dt.day, dt.hour, 0, 0);
      final double miss = _solarMiss(jd);
      if (miss < minMiss) {
        minMiss = miss;
        roughJD = jd;
      }
    }

    // Pass 2 — 1-min steps over ±60 min around rough peak
    double fineJD = roughJD;
    double fineMiss = minMiss;
    for (int m = -60; m <= 60; m++) {
      final double jd = roughJD + m / 1440.0;
      final double miss = _solarMiss(jd);
      if (miss < fineMiss) {
        fineMiss = miss;
        fineJD = jd;
      }
    }
    return fineJD;
  }

  // ── Sparsha / Moksha (lunar) ──────────────────────────────────────────────

  /// Scan backward from [maxJD] at 1-min steps to find when shadow miss
  /// first rises above [threshold] — this is Sparsha (first contact).
  static DateTime _findLunarSparsha(double maxJD, double threshold) {
    for (int m = 1; m <= 1440; m++) {
      final double jd = maxJD - m / 1440.0;
      if (_shadowMiss(jd) >= threshold) {
        // Refine to nearest 10 seconds
        for (int s = 0; s <= 60; s += 10) {
          final double jd2 = jd + s / 86400.0;
          if (_shadowMiss(jd2) < threshold) {
            return JulianDay.toIST(jd2);
          }
        }
        return JulianDay.toIST(jd + 30.0 / 86400.0);
      }
    }
    return JulianDay.toIST(maxJD - 3.0 / 24.0); // fallback
  }

  /// Scan forward from [maxJD] at 1-min steps to find when shadow miss
  /// rises above [threshold] — this is Moksha (last contact).
  static DateTime _findLunarMoksha(double maxJD, double threshold) {
    for (int m = 1; m <= 1440; m++) {
      final double jd = maxJD + m / 1440.0;
      if (_shadowMiss(jd) >= threshold) {
        for (int s = 0; s <= 60; s += 10) {
          final double jd2 = jd - s / 86400.0;
          if (_shadowMiss(jd2) < threshold) {
            return JulianDay.toIST(jd2);
          }
        }
        return JulianDay.toIST(jd - 30.0 / 86400.0);
      }
    }
    return JulianDay.toIST(maxJD + 3.0 / 24.0); // fallback
  }

  // ── Sparsha / Moksha (solar — shadow geometry) ────────────────────────────

  /// Scan backward from [maxJD] at 1-min steps to find when Moon–Sun miss
  /// first rises above [threshold] — this is Sparsha (first contact).
  static DateTime _findSolarSparsha(double maxJD, double threshold) {
    for (int m = 1; m <= 1440; m++) {
      final double jd = maxJD - m / 1440.0;
      if (_solarMiss(jd) >= threshold) {
        // Refine to nearest 10 seconds
        for (int s = 0; s <= 60; s += 10) {
          final double jd2 = jd + s / 86400.0;
          if (_solarMiss(jd2) < threshold) {
            return JulianDay.toIST(jd2);
          }
        }
        return JulianDay.toIST(jd + 30.0 / 86400.0);
      }
    }
    return JulianDay.toIST(maxJD - 3.0 / 24.0); // fallback
  }

  /// Scan forward from [maxJD] at 1-min steps to find when Moon–Sun miss
  /// rises above [threshold] — this is Moksha (last contact).
  static DateTime _findSolarMoksha(double maxJD, double threshold) {
    for (int m = 1; m <= 1440; m++) {
      final double jd = maxJD + m / 1440.0;
      if (_solarMiss(jd) >= threshold) {
        for (int s = 0; s <= 60; s += 10) {
          final double jd2 = jd - s / 86400.0;
          if (_solarMiss(jd2) < threshold) {
            return JulianDay.toIST(jd2);
          }
        }
        return JulianDay.toIST(jd - 30.0 / 86400.0);
      }
    }
    return JulianDay.toIST(maxJD + 3.0 / 24.0); // fallback
  }

  // ── Find all eclipses in a year ───────────────────────────────────────────

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

  // ── Eclipse checkers ──────────────────────────────────────────────────────

  static EclipseData? _checkSolarEclipse(double jd, DateTime date) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double rahu = rahuLongitude(jd);
    final double ketu = ketuLongitude(jd);
    final double distRahu = _angularDistance(moonLon, rahu);
    final double distKetu = _angularDistance(moonLon, ketu);

    const double solarEclipseLimit = 17.0;

    if (distRahu <= solarEclipseLimit || distKetu <= solarEclipseLimit) {
      // Find actual maximum using solar shadow geometry
      final double maxJD = _findSolarMaximumJD(date);
      final double minMiss = _solarMiss(maxJD);

      // Confirm eclipse: Moon must actually overlap Sun's disk
      if (minMiss >= _solarContact) return null;

      final double nodeDist = distRahu < distKetu ? distRahu : distKetu;
      final EclipseType type = nodeDist < 9
          ? EclipseType.solarTotal
          : nodeDist < 14
              ? EclipseType.solarAnnular
              : EclipseType.solarPartial;

      // Contact times using solar shadow geometry
      final DateTime sparsha = _findSolarSparsha(maxJD, _solarContact);
      final DateTime moksha  = _findSolarMoksha(maxJD, _solarContact);
      final DateTime maxIST  = JulianDay.toIST(maxJD);

      return EclipseData(
        date: date,
        type: type,
        sparsha: sparsha,
        moksha: moksha,
        sutakStart: sparsha.subtract(const Duration(hours: 12)),
        sutakStartVulnerable: sparsha.subtract(const Duration(hours: 4)),
        isVisibleInIndia: _solarVisibleFromIndia(maxIST),
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

    if (distRahu > lunarEclipseLimit && distKetu > lunarEclipseLimit) {
      return null; // not near a node — no eclipse possible
    }

    // Find actual maximum using shadow geometry
    final double maxJD = _findLunarMaximumJD(date);
    final double missDist = _shadowMiss(maxJD);

    // No eclipse if miss-distance exceeds penumbral contact limit
    if (missDist >= _penumbralContact) return null;

    // Classify by minimum miss-distance
    final EclipseType type = missDist < _totalContact
        ? EclipseType.lunarTotal
        : missDist < _umbralContact
            ? EclipseType.lunarPartial
            : EclipseType.lunarPenumbral;

    // Contact times using shadow geometry
    final double contactThreshold =
        type == EclipseType.lunarPenumbral ? _penumbralContact : _umbralContact;

    final DateTime sparsha = _findLunarSparsha(maxJD, contactThreshold);
    final DateTime moksha  = _findLunarMoksha(maxJD, contactThreshold);

    final double nodeDist = distRahu < distKetu ? distRahu : distKetu;

    return EclipseData(
      date: date,
      type: type,
      sparsha: sparsha,
      moksha: moksha,
      sutakStart: sparsha.subtract(const Duration(hours: 9)),
      sutakStartVulnerable: sparsha.subtract(const Duration(hours: 3)),
      isVisibleInIndia: _lunarVisibleFromIndia(sparsha, moksha),
      moonSunDiff: Tithi.moonSunDiff(jd),
      nodeDistance: nodeDist,
    );
  }

  // ── India visibility ──────────────────────────────────────────────────────

  /// Solar eclipse: visible from India if the geocentric maximum falls during
  /// IST daytime (06:00–18:30). India must be on the sunlit hemisphere.
  /// NOTE: full ground-track geometry (for path-over-India check) is deferred.
  static bool _solarVisibleFromIndia(DateTime maxIST) {
    final int minuteOfDay = maxIST.hour * 60 + maxIST.minute;
    return minuteOfDay >= 360 && minuteOfDay <= 1110; // 06:00–18:30
  }

  /// Lunar eclipse: visible from India if any part of [sparsha, moksha]
  /// overlaps with IST nighttime (18:00–06:00). At full moon the Moon is
  /// above India's horizon from sunset to sunrise.
  static bool _lunarVisibleFromIndia(DateTime sparsha, DateTime moksha) {
    bool nightHour(int h) => h >= 18 || h < 6;
    return nightHour(sparsha.hour) ||
        nightHour(moksha.hour) ||
        sparsha.day != moksha.day; // spans midnight → covers some nighttime
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
