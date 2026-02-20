import 'dart:math' as math;
import 'julian_day.dart';
import 'lunar_position.dart';

/// Moonrise and moonset calculation.
///
/// Uses the same hour-angle method as sunrise but for the Moon.
/// Moon's standard altitude h0 accounts for parallax and refraction.
/// Accuracy: ±5 minutes.
///
/// All returned DateTimes are in IST (UTC+5:30).
class MoonriseMoonset {
  MoonriseMoonset._();

  // Standard altitude for Moon (refraction 34' - semi-diameter ~15' + parallax ~57')
  // h0 = 0.7275 * HP - 0.5667 ≈ 0.7275 * 0.9507 - 0.5667 ≈ 0.125°
  static const double _h0Moon = 0.125; // degrees

  /// Compute moonrise and moonset for a given date and location.
  ///
  /// Returns [moonrise, moonset] where either can be null (Moon above/below horizon all day).
  static List<DateTime?> compute(DateTime date, double lat, double lng) {
    final double jd0 =
        JulianDay.fromDateTime(date.year, date.month, date.day);

    final DateTime? rise = _findEvent(jd0, lat, lng, rising: true);
    final DateTime? set_ = _findEvent(jd0, lat, lng, rising: false);

    return [rise, set_];
  }

  static DateTime? _findEvent(
    double jd0,
    double lat,
    double lng,
    {required bool rising}
  ) {
    // Search in 24h window; Moon can rise/set any time of day
    // Use binary search between jd0 and jd0+1
    double lo = jd0;
    double hi = jd0 + 1.0;

    // Check if event occurs in this window by evaluating altitude at lo and hi
    final double altLo = _altitude(lo, lat, lng);
    final double altHi = _altitude(hi, lat, lng);

    // Check if the sign changes (Moon crosses horizon)
    // For rise: altitude goes from negative to positive
    // For set: altitude goes from positive to negative
    bool eventFound = rising
        ? (altLo < _h0Moon && altHi > _h0Moon) ||
              _hasCrossing(jd0, lat, lng, lo, hi, rising)
        : (altLo > _h0Moon && altHi < _h0Moon) ||
              _hasCrossing(jd0, lat, lng, lo, hi, rising);

    if (!eventFound) {
      // Try searching in a wider window to find the crossing
      final jdMid = (lo + hi) / 2;
      final altMid = _altitude(jdMid, lat, lng);
      if (rising) {
        if (altLo < _h0Moon && altMid > _h0Moon) {
          hi = jdMid;
          eventFound = true;
        } else if (altMid < _h0Moon && altHi > _h0Moon) {
          lo = jdMid;
          eventFound = true;
        }
      } else {
        if (altLo > _h0Moon && altMid < _h0Moon) {
          hi = jdMid;
          eventFound = true;
        } else if (altMid > _h0Moon && altHi < _h0Moon) {
          lo = jdMid;
          eventFound = true;
        }
      }
    }

    if (!eventFound) return null;

    // Binary search to find the crossing
    for (int i = 0; i < 60; i++) {
      final double mid = (lo + hi) / 2;
      final double altMid = _altitude(mid, lat, lng);

      if (rising) {
        if (altMid < _h0Moon) {
          lo = mid;
        } else {
          hi = mid;
        }
      } else {
        if (altMid > _h0Moon) {
          lo = mid;
        } else {
          hi = mid;
        }
      }

      if ((hi - lo) * 86400 < 60) break; // 1 minute precision
    }

    return JulianDay.toIST((lo + hi) / 2);
  }

  static bool _hasCrossing(
    double jd0,
    double lat,
    double lng,
    double lo,
    double hi,
    bool rising,
  ) {
    // Check multiple points in the window
    const int steps = 12;
    double prevAlt = _altitude(lo, lat, lng);
    for (int i = 1; i <= steps; i++) {
      final double jd = lo + (hi - lo) * i / steps;
      final double alt = _altitude(jd, lat, lng);
      if (rising && prevAlt < _h0Moon && alt > _h0Moon) return true;
      if (!rising && prevAlt > _h0Moon && alt < _h0Moon) return true;
      prevAlt = alt;
    }
    return false;
  }

  /// Moon's altitude above horizon in degrees at a given JD, lat, lng.
  static double _altitude(double jd, double lat, double lng) {
    final List<double> coords = LunarPosition.equatorialCoords(jd);
    final double ra = coords[0];
    final double dec = coords[1];

    // Greenwich Sidereal Time
    final double T = JulianDay.julianCentury(jd);
    double gst = 280.46061837 +
        360.98564736629 * (jd - JulianDay.j2000) +
        0.000387933 * T * T;
    gst = JulianDay.normalize360(gst);

    // Local hour angle
    final double lha = JulianDay.normalize360(gst + lng - ra);

    final double latRad = JulianDay.toRad(lat);
    final double decRad = JulianDay.toRad(dec);
    final double lhaRad = JulianDay.toRad(lha);

    final double sinAlt = math.sin(latRad) * math.sin(decRad) +
        math.cos(latRad) * math.cos(decRad) * math.cos(lhaRad);
    return JulianDay.toDeg(math.asin(sinAlt.clamp(-1.0, 1.0)));
  }
}
