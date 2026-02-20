import 'dart:math' as math;

/// Julian Day Number utilities.
///
/// The Julian Day Number (JD) is the continuous count of days since the
/// beginning of the Julian Period (Jan 1, 4713 BC). It is the universal
/// time base for all astronomical calculations.
///
/// J2000.0 = JD 2451545.0 (Jan 1.5, 2000 = Jan 1, 2000, 12:00 TT)
class JulianDay {
  JulianDay._();

  static const double j2000 = 2451545.0;
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Compute the Julian Day Number for a given Gregorian calendar date/time (UT).
  ///
  /// Parameters are in Universal Time (UT). For Indian Standard Time (IST),
  /// subtract 5h 30m before calling this function.
  static double fromDateTime(int year, int month, int day,
      [int hour = 0, int minute = 0, int second = 0]) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final int a = y ~/ 100;
    final int b = 2 - a + (a ~/ 4); // Gregorian calendar correction

    final double dayFraction =
        day + hour / 24.0 + minute / 1440.0 + second / 86400.0;

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        dayFraction +
        b -
        1524.5;
  }

  /// Convert a Dart [DateTime] (treated as IST) to Julian Day Number in UT.
  static double fromIST(DateTime ist) {
    final utc = ist.subtract(istOffset);
    return fromDateTime(
      utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second,
    );
  }

  /// Convert a Julian Day Number (UT) to Dart [DateTime] in IST.
  static DateTime toIST(double jd) {
    final utc = toUTC(jd);
    return utc.add(istOffset);
  }

  /// Convert a Julian Day Number (UT) to Dart [DateTime] in UTC.
  static DateTime toUTC(double jd) {
    final int z = (jd + 0.5).floor();
    final double f = jd + 0.5 - z;

    int a = z;
    if (z >= 2299161) {
      final int alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha ~/ 4);
    }
    final int b = a + 1524;
    final int c = ((b - 122.1) / 365.25).floor();
    final int d = (365.25 * c).floor();
    final int e = ((b - d) / 30.6001).floor();

    final double dayWithFraction = (b - d - (30.6001 * e).floor()) + f;
    final int day = dayWithFraction.floor();
    final double hourFraction = (dayWithFraction - day) * 24.0;
    final int hour = hourFraction.floor();
    final double minuteFraction = (hourFraction - hour) * 60.0;
    final int minute = minuteFraction.floor();
    final int second = ((minuteFraction - minute) * 60.0).round();

    final int month = e < 14 ? e - 1 : e - 13;
    final int year = month > 2 ? c - 4716 : c - 4715;

    return DateTime.utc(year, month, day, hour, minute, second.clamp(0, 59));
  }

  /// Julian centuries since J2000.0 (the standard T for most formulas).
  static double julianCentury(double jd) => (jd - j2000) / 36525.0;

  /// Degrees to radians.
  static double toRad(double deg) => deg * math.pi / 180.0;

  /// Radians to degrees.
  static double toDeg(double rad) => rad * 180.0 / math.pi;

  /// Normalize an angle to [0, 360).
  static double normalize360(double deg) => ((deg % 360.0) + 360.0) % 360.0;
}
