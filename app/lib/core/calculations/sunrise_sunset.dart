import 'dart:math' as math;
import 'julian_day.dart';
import 'solar_position.dart';

/// Sunrise and sunset calculation.
///
/// Based on Jean Meeus "Astronomical Algorithms" Chapter 15.
/// Accuracy: ±1 minute for India latitudes.
///
/// All returned DateTimes are in IST (UTC+5:30).
class SunriseSunset {
  SunriseSunset._();

  /// Standard altitude for sunrise/sunset (accounts for refraction + semi-diameter).
  static const double _h0Sun = -0.8333; // degrees

  /// Compute sunrise and sunset for a given date and location.
  ///
  /// [date] — the calendar date (day, month, year used, time ignored)
  /// [lat] — latitude in degrees (positive = north)
  /// [lng] — longitude in degrees (positive = east)
  ///
  /// Returns [sunrise, sunset] as IST DateTimes.
  static List<DateTime> compute(DateTime date, double lat, double lng) {
    // Step 1: JD at 0h UT of the date
    final DateTime d0 = DateTime.utc(date.year, date.month, date.day);
    final double jd0 = JulianDay.fromDateTime(d0.year, d0.month, d0.day);

    // Step 2: Approximate times (fractional day, 0=midnight UT)
    final double lngHours = lng / 15.0; // longitude in hours
    final double noonUT = 0.5 - lngHours / 24.0; // approximate transit

    double riseApprox = _iterateSun(jd0, noonUT - (6.0 / 24.0), lat, lng,
        _h0Sun, rising: true);
    double setApprox = _iterateSun(jd0, noonUT + (6.0 / 24.0), lat, lng,
        _h0Sun, rising: false);

    final DateTime sunrise = JulianDay.toIST(jd0 + riseApprox);
    final DateTime sunset = JulianDay.toIST(jd0 + setApprox);

    return [sunrise, sunset];
  }

  /// Iterative refinement of sunrise/sunset time.
  /// Returns fractional day (0–1 range, UT) offset from jd0.
  static double _iterateSun(
    double jd0,
    double initialGuess,
    double lat,
    double lng,
    double h0,
    {required bool rising}
  ) {
    double t = initialGuess;
    for (int i = 0; i < 5; i++) {
      final double jd = jd0 + t;
      final double dec = SolarPosition.declination(jd);

      // Hour angle H (degrees)
      final double cosH =
          (_sinAlt(h0) - _sinLat(lat) * _sin(dec)) /
          (_cosLat(lat) * _cos(dec));

      if (cosH < -1.0 || cosH > 1.0) {
        // Sun never rises/sets (polar day/night) — return noon
        return 0.5;
      }

      // Altitude correction (Meeus eq. 15.2)
      final double h_actual = _computeAltitude(jd, lat, lng);
      final double delta_t = (h_actual - h0) /
          (360.0 * _cos(_asin(_sinAlt(h_actual))) * _cosLat(lat) * _cos(dec));

      t = t - delta_t;
    }
    return t.clamp(0.0, 1.0);
  }

  /// Simpler, more reliable sunrise computation using the NOAA algorithm.
  /// This is the primary method used in production.
  static List<DateTime> computeNOAA(DateTime date, double lat, double lng) {
    // JD at noon UT on this date
    final double jdNoon = JulianDay.fromDateTime(
      date.year, date.month, date.day, 12, 0, 0,
    );
    // Sun's coordinates at noon
    final double dec = SolarPosition.declination(jdNoon);
    // Equation of time (minutes)
    final double eqTime = _equationOfTime(jdNoon);

    // Hour angle at sunrise/sunset
    final double cosH =
        (_sinAlt(_h0Sun) - _sinLat(lat) * _sin(dec)) /
        (_cosLat(lat) * _cos(dec));

    if (cosH < -1.0 || cosH > 1.0) {
      // Polar day/night — return midday for both
      final DateTime noon = JulianDay.toIST(jdNoon);
      return [noon, noon];
    }

    final double HA = _acos(cosH); // degrees

    // Solar noon in fractional hours (UT)
    final double solarNoonUT = 12.0 - lng / 15.0 - eqTime / 60.0;
    final double sunriseUT = solarNoonUT - HA / 15.0;
    final double sunsetUT = solarNoonUT + HA / 15.0;

    // Base JD at 0h UT
    final double jd0 =
        JulianDay.fromDateTime(date.year, date.month, date.day);

    final DateTime sunrise = JulianDay.toIST(jd0 + sunriseUT / 24.0);
    final DateTime sunset = JulianDay.toIST(jd0 + sunsetUT / 24.0);

    return [sunrise, sunset];
  }

  /// Equation of time in minutes for a given JD.
  static double _equationOfTime(double jd) {
    final double T = JulianDay.julianCentury(jd);
    final double eps0 = 23.439291111 - 0.013004167 * T;
    final double l0 = 280.46646 + 36000.76983 * T;
    final double M = 357.52911 + 35999.05029 * T;
    final double e = 0.016708634 - 0.000042037 * T;
    final double y = math.pow(math.tan(JulianDay.toRad(eps0 / 2)), 2) as double;

    final double l0rad = JulianDay.toRad(l0);
    final double Mrad = JulianDay.toRad(M);

    final double eqt = y * math.sin(2 * l0rad) -
        2 * e * math.sin(Mrad) +
        4 * e * y * math.sin(Mrad) * math.cos(2 * l0rad) -
        0.5 * y * y * math.sin(4 * l0rad) -
        1.25 * e * e * math.sin(2 * Mrad);

    return JulianDay.toDeg(eqt) * 4; // minutes
  }

  /// Greenwich Sidereal Time at 0h UT in degrees.
  static double _greenwichSiderealTime(double jd0) {
    final double T = JulianDay.julianCentury(jd0);
    double theta = 100.4606184 + 36000.770053 * T + 0.000387933 * T * T;
    return JulianDay.normalize360(theta);
  }

  /// Compute actual altitude of sun at a given JD for iterative correction.
  static double _computeAltitude(double jd, double lat, double lng) {
    final double dec = SolarPosition.declination(jd);
    final double ra = SolarPosition.rightAscension(jd);
    final double theta = _greenwichSiderealTime(jd.floor().toDouble()) +
        (jd - jd.floor()) * 360.98564724;
    final double lha = JulianDay.normalize360(theta + lng - ra);
    return JulianDay.toDeg(math.asin(
      _sinLat(lat) * _sin(dec) +
          _cosLat(lat) * _cos(dec) * _cos(lha),
    ));
  }

  // Helper trig functions to keep code readable
  static double _sin(double deg) => math.sin(JulianDay.toRad(deg));
  static double _cos(double deg) => math.cos(JulianDay.toRad(deg));
  static double _acos(double x) => JulianDay.toDeg(math.acos(x.clamp(-1, 1)));
  static double _asin(double x) => JulianDay.toDeg(math.asin(x.clamp(-1, 1)));
  static double _sinAlt(double alt) => _sin(alt);
  static double _sinLat(double lat) => _sin(lat);
  static double _cosLat(double lat) => _cos(lat);
}
