import 'dart:math' as math;
import 'julian_day.dart';

/// Moon position using Surya Siddhanta planetary constants.
///
/// Surya Siddhanta is the classical Indian astronomical text used by
/// traditional Panchangam makers including Sringeri. It computes
/// directly in the sidereal (nirayana) frame — 0° Aries is fixed to
/// stellar positions, not the vernal equinox. NO ayanamsha subtraction
/// is needed: the output is already nirayana by construction.
///
/// Constants (Surya Siddhanta, Chapter 1 — Revolutions of Planets):
///   Epoch:    Kali Yuga start, JD 588465.5 (Feb 17, 3102 BCE, proleptic Julian)
///   Mahayuga: 4,320,000 Julian years = 1,577,917,828 civil days
///   Moon revolutions per Mahayuga:        57,753,336
///   Moon apogee (mandocca) revolutions:      488,219
///
/// Manda correction (Chapter 2):
///   Epicycle radius: 31.5 parts out of 360
///   correction = arcsin(31.5 / 360 × sin(anomaly))  → max ~5.05°
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
  /// Surya Siddhanta computes directly in sidereal (nirayana) frame —
  /// 0° Aries is fixed to stellar background, NOT the vernal equinox.
  /// No ayanamsha subtraction is needed or correct here.
  ///
  /// Drop-in replacement for [LunarPosition.siderealLongitude].
  static double siderealLongitude(double jd) {
    return _trueLongitude(jd);
  }

  /// Moon's true longitude in SS nirayana frame (mean + manda correction).
  static double _trueLongitude(double jd) {
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
