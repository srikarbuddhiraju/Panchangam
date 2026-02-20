import 'dart:math' as math;
import 'julian_day.dart';
import 'ayanamsa.dart';

/// Moon position calculations.
///
/// Based on Jean Meeus "Astronomical Algorithms" Chapter 47.
/// Uses the full 60-term series from Table 47.A for ~0.003° accuracy.
/// Accuracy: ±0.01° in longitude — sufficient for Tithi/Nakshatra to ±2 min.
class LunarPosition {
  LunarPosition._();

  // Table 47.A from Meeus — periodic terms for Moon's longitude.
  // Columns: D, M, M', F, ΣL (in 10^-6 degrees, includes E correction marker)
  // 'e' flag: if |M| terms need E factor (1 = yes for |M|=1, 2 = yes for |M|=2)
  // We apply E correction inline.
  static const List<List<int>> _lonTerms = [
    // D,  M,  M', F,   ΣL
    [0, 0, 1, 0, 6288774],
    [2, 0, -1, 0, 1274027],
    [2, 0, 0, 0, 658314],
    [0, 0, 2, 0, 213618],
    [0, 1, 0, 0, -185116],
    [0, 0, 0, 2, -114332],
    [2, 0, -2, 0, 58793],
    [2, -1, -1, 0, 57066],
    [2, 0, 1, 0, 53322],
    [2, -1, 0, 0, 45758],
    [0, 1, -1, 0, -40923],
    [1, 0, 0, 0, -34720],
    [0, 1, 1, 0, -30383],
    [2, 0, 0, -2, 15327],
    [0, 0, 1, 2, -12528],
    [0, 0, 1, -2, 10980],
    [4, 0, -1, 0, 10675],
    [0, 0, 3, 0, 10034],
    [4, 0, -2, 0, 8548],
    [2, 1, -1, 0, -7888],
    [2, 1, 0, 0, -6766],
    [1, 0, -1, 0, -5163],
    [1, 1, 0, 0, 4987],
    [2, -1, 1, 0, 4036],
    [2, 0, 2, 0, 3994],
    [4, 0, 0, 0, 3861],
    [2, 0, -3, 0, 3665],
    [0, 1, -2, 0, -2689],
    [2, 0, -1, 2, -2602],
    [2, -1, -2, 0, 2390],
    [1, 0, 1, 0, -2348],
    [2, -2, 0, 0, 2236],
    [0, 1, 2, 0, -2120],
    [0, 2, 0, 0, -2069],
    [2, -2, -1, 0, 2048],
    [2, 0, 1, -2, -1773],
    [2, 0, 0, 2, -1595],
    [4, -1, -1, 0, 1215],
    [0, 0, 2, 2, -1110],
    [3, 0, -1, 0, -892],
    [2, 1, 1, 0, -810],
    [4, -1, -2, 0, 759],
    [0, 2, -1, 0, -713],
    [2, 2, -1, 0, -700],
    [2, 1, -2, 0, 691],
    [2, -1, 0, -2, 596],
    [4, 0, 1, 0, 549],
    [0, 0, 4, 0, 537],
    [4, -1, 0, 0, 520],
    [1, 0, -2, 0, -487],
    [2, 1, 0, -2, -399],
    [0, 0, 2, -2, -381],
    [1, 1, 1, 0, 351],
    [3, 0, -2, 0, -340],
    [4, 0, -3, 0, 330],
    [2, -1, 2, 0, 327],
    [0, 2, 1, 0, -323],
    [1, 1, -1, 0, 299],
    [2, 0, 3, 0, 294],
    [2, 0, -1, -2, 0],
  ];

  /// Moon's sidereal longitude in degrees for a given JD (UT).
  static double siderealLongitude(double jd) {
    return Ayanamsa.toSidereal(tropicalLongitude(jd), jd);
  }

  /// Moon's tropical longitude in degrees for a given JD (UT).
  static double tropicalLongitude(double jd) {
    final double T = JulianDay.julianCentury(jd);
    final T2 = T * T;
    final T3 = T2 * T;
    final T4 = T3 * T;

    // Moon's mean longitude (degrees)
    double Lp = 218.3164477 +
        481267.88123421 * T -
        0.0015786 * T2 +
        T3 / 538841.0 -
        T4 / 65194000.0;

    // Moon's mean elongation (degrees)
    double D = 297.8501921 +
        445267.1114034 * T -
        0.0018819 * T2 +
        T3 / 545868.0 -
        T4 / 113065000.0;

    // Sun's mean anomaly (degrees)
    double M = 357.5291092 +
        35999.0502909 * T -
        0.0001536 * T2 +
        T3 / 24490000.0;

    // Moon's mean anomaly (degrees)
    double Mp = 134.9633964 +
        477198.8675055 * T +
        0.0087414 * T2 +
        T3 / 69699.0 -
        T4 / 14712000.0;

    // Moon's argument of latitude (degrees)
    double F = 93.2720950 +
        483202.0175233 * T -
        0.0036539 * T2 -
        T3 / 3526000.0 +
        T4 / 863310000.0;

    // Correction for eccentricity of Earth's orbit
    final double E = 1.0 - 0.002516 * T - 0.0000074 * T2;
    final double E2 = E * E;

    // Normalize
    D = JulianDay.normalize360(D);
    M = JulianDay.normalize360(M);
    Mp = JulianDay.normalize360(Mp);
    F = JulianDay.normalize360(F);
    Lp = JulianDay.normalize360(Lp);

    final double Drad = JulianDay.toRad(D);
    final double Mrad = JulianDay.toRad(M);
    final double Mprad = JulianDay.toRad(Mp);
    final double Frad = JulianDay.toRad(F);

    double sumL = 0.0;
    for (final term in _lonTerms) {
      final int d = term[0];
      final int m = term[1];
      final int mp = term[2];
      final int f = term[3];
      final int coef = term[4];
      if (coef == 0) continue;

      double eFactor = 1.0;
      if (m.abs() == 1) eFactor = E;
      if (m.abs() == 2) eFactor = E2;

      final double arg =
          d * Drad + m * Mrad + mp * Mprad + f * Frad;
      sumL += coef * eFactor * math.sin(arg);
    }

    // Additional correction terms (Meeus eq. 47.1)
    double A1 = 119.75 + 131.849 * T;
    double A2 = 53.09 + 479264.290 * T;
    double A3 = 313.45 + 481266.484 * T;
    A1 = JulianDay.normalize360(A1);
    A2 = JulianDay.normalize360(A2);
    A3 = JulianDay.normalize360(A3);

    sumL += 3958 * math.sin(JulianDay.toRad(A1)) +
        1962 * math.sin(JulianDay.toRad(Lp - F)) +
        318 * math.sin(JulianDay.toRad(A2));

    // Moon's true longitude (degrees)
    final double moonLon = Lp + sumL / 1000000.0;

    return JulianDay.normalize360(moonLon);
  }

  /// Moon's right ascension and declination for a given JD (UT).
  /// Returns [rightAscension, declination] in degrees.
  static List<double> equatorialCoords(double jd) {
    final double T = JulianDay.julianCentury(jd);
    // Obliquity of the ecliptic
    final double eps = 23.439291111 -
        0.013004167 * T -
        0.0001638 * T * T +
        0.0005037 * T * T * T;

    // Moon's latitude (simplified, from Meeus Table 47.B — key terms only)
    final double lon = tropicalLongitude(jd);
    // For declination, we need latitude too. Use simplified beta:
    final double beta = _latitude(jd);

    final double lonRad = JulianDay.toRad(lon);
    final double latRad = JulianDay.toRad(beta);
    final double epsRad = JulianDay.toRad(eps);

    final double ra = JulianDay.normalize360(JulianDay.toDeg(math.atan2(
      math.sin(lonRad) * math.cos(epsRad) -
          math.tan(latRad) * math.sin(epsRad),
      math.cos(lonRad),
    )));
    final double dec = JulianDay.toDeg(math.asin(
      math.sin(latRad) * math.cos(epsRad) +
          math.cos(latRad) * math.sin(epsRad) * math.sin(lonRad),
    ));
    return [ra, dec];
  }

  /// Moon's ecliptic latitude in degrees (simplified, main terms only).
  static double _latitude(double jd) {
    final double T = JulianDay.julianCentury(jd);
    final T2 = T * T;
    final T3 = T2 * T;
    final T4 = T3 * T;

    double D = 297.8501921 + 445267.1114034 * T - 0.0018819 * T2 +
        T3 / 545868.0 - T4 / 113065000.0;
    double M = 357.5291092 + 35999.0502909 * T - 0.0001536 * T2 +
        T3 / 24490000.0;
    double Mp = 134.9633964 + 477198.8675055 * T + 0.0087414 * T2 +
        T3 / 69699.0 - T4 / 14712000.0;
    double F = 93.2720950 + 483202.0175233 * T - 0.0036539 * T2 -
        T3 / 3526000.0 + T4 / 863310000.0;

    D = JulianDay.normalize360(D);
    M = JulianDay.normalize360(M);
    Mp = JulianDay.normalize360(Mp);
    F = JulianDay.normalize360(F);

    final double E = 1.0 - 0.002516 * T - 0.0000074 * T2;

    // Key latitude terms from Table 47.B
    double sumB = 5128122 * math.sin(JulianDay.toRad(F)) +
        280602 * math.sin(JulianDay.toRad(Mp + F)) +
        277693 * math.sin(JulianDay.toRad(Mp - F)) +
        173237 * math.sin(JulianDay.toRad(2 * D - F)) +
        55413 *
            math.sin(JulianDay.toRad(2 * D - Mp + F)) * E +
        46271 *
            math.sin(JulianDay.toRad(2 * D - Mp - F)) * E +
        32573 * math.sin(JulianDay.toRad(2 * D + F)) +
        17198 * math.sin(JulianDay.toRad(2 * Mp + F)) +
        9266 * math.sin(JulianDay.toRad(2 * D + Mp - F)) +
        8822 * math.sin(JulianDay.toRad(2 * Mp - F)) +
        8216 * math.sin(JulianDay.toRad(2 * D - M - F)) * E +
        4324 * math.sin(JulianDay.toRad(2 * D - 2 * Mp - F)) +
        4200 * math.sin(JulianDay.toRad(2 * D + Mp + F));

    // Correction: A1
    double A1 = 119.75 + 131.849 * T;
    A1 = JulianDay.normalize360(A1);
    sumB -= 2235 * math.sin(JulianDay.toRad(F)) +
        382 * math.sin(JulianDay.toRad(A1));

    return sumB / 1000000.0;
  }

  /// Moon's horizontal parallax in degrees (used for moonrise corrections).
  static double horizontalParallax(double jd) {
    // Simplified: return average horizontal parallax (~57')
    // Full calculation requires Sigma-r from Meeus Ch.47
    return 0.9507; // degrees
  }
}
