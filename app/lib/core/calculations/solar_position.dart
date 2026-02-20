import 'dart:math' as math;
import 'julian_day.dart';
import 'ayanamsa.dart';

/// Sun position calculations.
///
/// Based on Jean Meeus "Astronomical Algorithms" Chapter 25 (low precision).
/// Accuracy: ±0.01° in longitude — sufficient for Panchangam purposes.
class SolarPosition {
  SolarPosition._();

  /// Sun's apparent tropical longitude in degrees for a given JD (UT).
  static double tropicalLongitude(double jd) {
    final double T = JulianDay.julianCentury(jd);

    // Geometric mean longitude of the sun (degrees)
    double L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T;
    L0 = JulianDay.normalize360(L0);

    // Mean anomaly of the sun (degrees)
    double M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T;
    M = JulianDay.normalize360(M);
    final double Mrad = JulianDay.toRad(M);

    // Sun's equation of center
    final double C = (1.914602 - 0.004817 * T - 0.000014 * T * T) *
            math.sin(Mrad) +
        (0.019993 - 0.000101 * T) * math.sin(2 * Mrad) +
        0.000289 * math.sin(3 * Mrad);

    // Sun's true longitude
    final double sunLon = L0 + C;

    // Apparent longitude (correct for nutation and aberration)
    double omega = 125.04 - 1934.136 * T;
    omega = JulianDay.normalize360(omega);
    final double apparent =
        sunLon - 0.00569 - 0.00478 * math.sin(JulianDay.toRad(omega));

    return JulianDay.normalize360(apparent);
  }

  /// Sun's sidereal longitude (Lahiri ayanamsa applied) in degrees.
  static double siderealLongitude(double jd) {
    return Ayanamsa.toSidereal(tropicalLongitude(jd), jd);
  }

  /// Sun's declination in degrees for a given JD (UT).
  static double declination(double jd) {
    final double T = JulianDay.julianCentury(jd);
    // Obliquity of the ecliptic
    final double eps = 23.439291111 -
        0.013004167 * T -
        0.0001638 * T * T +
        0.0005037 * T * T * T;
    final double lon = tropicalLongitude(jd);
    return JulianDay.toDeg(
      math.asin(math.sin(JulianDay.toRad(eps)) * math.sin(JulianDay.toRad(lon))),
    );
  }

  /// Sun's right ascension in degrees for a given JD (UT).
  static double rightAscension(double jd) {
    final double T = JulianDay.julianCentury(jd);
    final double eps = 23.439291111 -
        0.013004167 * T -
        0.0001638 * T * T +
        0.0005037 * T * T * T;
    final double lon = tropicalLongitude(jd);
    final double ra = JulianDay.toDeg(math.atan2(
      math.cos(JulianDay.toRad(eps)) * math.sin(JulianDay.toRad(lon)),
      math.cos(JulianDay.toRad(lon)),
    ));
    return JulianDay.normalize360(ra);
  }

  /// Mean anomaly of the Sun in degrees (used for sunrise iteration).
  static double meanAnomaly(double jd) {
    final double T = JulianDay.julianCentury(jd);
    double M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T;
    return JulianDay.normalize360(M);
  }
}
