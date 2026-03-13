import 'dart:math' as math;
import 'julian_day.dart';

/// Ayanamsa — sidereal correction for Indian astronomical calculations.
///
/// Tropical longitude − Ayanamsa = Sidereal (Nirayana) longitude
///
/// Production path: True Chitra Paksha (Mean Lahiri + nutation in longitude).
/// This is the most precise definition: Spica (Chitra) = 180° true sidereal.
///
/// Mean Lahiri constants (Government of India, official):
///   Epoch J1900.0: JD = 2415020.0, ayanamsa = 22°27'38" = 22.46055556°
///   Annual precession rate: 50.2388475 arc-seconds/year
///
/// Nutation correction (Meeus Ch. 22, 4 dominant terms):
///   Dominant term: −17.20" × sin(Ω), where Ω = Moon's ascending node longitude.
///   Total amplitude: ±17.2 arcseconds ≈ ±0.005° ≈ ±0.5 min on nakshatra timing.
class Ayanamsa {
  Ayanamsa._();

  static const double _epochJD = 2415020.0; // J1900.0
  static const double _epochAyanamsa = 22.46055556; // degrees at J1900.0
  static const double _annualRate = 50.2388475; // arc-seconds per year

  static double _toRad(double deg) => deg * math.pi / 180.0;

  /// Mean Lahiri Ayanamsa in degrees — constant precession rate from J1900.0.
  /// Use this for diagnostic scripts. Production code uses [trueChhitraPaksha].
  static double lahiri(double jd) {
    final double yearsSince1900 = (jd - _epochJD) / 365.25;
    return _epochAyanamsa + (_annualRate * yearsSince1900 / 3600.0);
  }

  /// Nutation in longitude (Δψ) in degrees.
  ///
  /// Source: Meeus, Astronomical Algorithms, 2nd ed., Ch. 22, Table 22.A.
  /// Four dominant terms retained; remaining terms sum to < 0.2".
  static double nutationInLongitude(double jd) {
    final double T = (jd - 2451545.0) / 36525.0; // centuries from J2000.0
    final double omega  = _toRad(125.04452   - 1934.136261  * T);
    final double lSun   = _toRad(280.4665    +   36000.7698 * T);
    final double lMoon  = _toRad(218.3165    +  481267.8813 * T);
    final double arcsec = -17.20 * math.sin(omega)
                          -  1.32 * math.sin(2 * lSun)
                          -  0.23 * math.sin(2 * lMoon)
                          +  0.21 * math.sin(2 * omega);
    return arcsec / 3600.0;
  }

  /// True Chitra Paksha Ayanamsa — Mean Lahiri corrected for nutation.
  ///
  /// This is the most astronomically precise Chitra Paksha value:
  /// it places Spica at exactly 180° on the TRUE (not mean) ecliptic.
  static double trueChhitraPaksha(double jd) {
    return lahiri(jd) + nutationInLongitude(jd);
  }

  /// Convert a tropical longitude to sidereal longitude (True Chitra Paksha).
  static double toSidereal(double tropicalLon, double jd) {
    return JulianDay.normalize360(tropicalLon - trueChhitraPaksha(jd));
  }
}
