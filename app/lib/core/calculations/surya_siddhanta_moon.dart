import 'dart:math' as math;
import 'julian_day.dart';
import 'ayanamsa.dart';

/// Moon position using Surya Siddhanta planetary constants.
///
/// The Surya Siddhanta is the classical Indian astronomical text used by
/// traditional Panchangam makers (including Sringeri "Surya Siddhanta
/// Panchangam"). Its Moon position differs from the modern Drik (Meeus/VSOP87)
/// primarily because it uses a smaller equation-of-center (~5.02° max vs
/// Drik ~6.29° max), causing Moon longitudes that lag Drik by ~1–2° in the
/// current era.
///
/// Constants (Surya Siddhanta, Chapter 1 — Revolutions of Planets):
///   Epoch:    Kali Yuga start, JD 588465.5 (Feb 17, 3102 BCE, proleptic Julian)
///   Mahayuga: 4,320,000 Julian years = 1,577,917,828 civil days
///   Moon revolutions per Mahayuga:        57,753,336
///   Moon apogee (mandocca) revolutions:      488,219
///
/// Equation of center (Manda correction, Chapter 2):
///   Epicycle radius: 31.5 parts (varies 31–32; mean 31.5 out of 360)
///   correction = arcsin(31.5 / 360 × sin(anomaly))  [in degrees]
///
/// Ayanamsha: Lahiri (same as used elsewhere in the app).
class SuryaSiddhantaMoon {
  SuryaSiddhantaMoon._();

  // ── Surya Siddhanta constants ────────────────────────────────────────────

  /// Kali Yuga epoch in Julian Days (UT).
  /// Feb 17/18, 3102 BCE proleptic Julian Calendar.
  static const double _epochJD = 588465.5;

  /// Civil days in one Mahayuga.
  static const double _mahayugaDays = 1577917828.0;

  /// Moon revolutions per Mahayuga.
  static const double _moonRevs = 57753336.0;

  /// Moon apogee (mandocca) revolutions per Mahayuga.
  static const double _apogeeRevs = 488219.0;

  /// Manda epicycle mean radius (parts out of 360 — the deferent circle).
  static const double _mandaRadius = 31.5;

  // ── Derived daily motions ─────────────────────────────────────────────────

  /// Moon's mean daily motion in degrees.
  static const double _moonDailyMotion =
      _moonRevs / _mahayugaDays * 360.0; // 13.17634906°/day

  /// Moon apogee mean daily motion in degrees.
  static const double _apogeeDailyMotion =
      _apogeeRevs / _mahayugaDays * 360.0; // 0.11140365°/day

  // ── Public API ────────────────────────────────────────────────────────────

  /// Moon's sidereal longitude in degrees for a given Julian Day (UT).
  ///
  /// Drop-in replacement for [LunarPosition.siderealLongitude].
  static double siderealLongitude(double jd) {
    return Ayanamsa.toSidereal(tropicalLongitude(jd), jd);
  }

  /// Moon's tropical longitude in degrees (Surya Siddhanta, before ayanamsha).
  static double tropicalLongitude(double jd) {
    final double elapsed = jd - _epochJD; // Kali days from epoch

    // Mean Moon longitude
    final double meanMoon =
        JulianDay.normalize360(elapsed * _moonDailyMotion);

    // Mean apogee (mandocca) longitude
    final double meanApogee =
        JulianDay.normalize360(elapsed * _apogeeDailyMotion);

    // Manda (anomaly) — Moon minus apogee
    final double anomaly = JulianDay.normalize360(meanMoon - meanApogee);
    final double anomalyRad = anomaly * math.pi / 180.0;

    // Manda correction (equation of center)
    // correction = arcsin(r/360 × sin(anomaly)), result in degrees
    final double correction = math.asin(
          (_mandaRadius / 360.0) * math.sin(anomalyRad),
        ) *
        180.0 /
        math.pi;

    return JulianDay.normalize360(meanMoon + correction);
  }
}
