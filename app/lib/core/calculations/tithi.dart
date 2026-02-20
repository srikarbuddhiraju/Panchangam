import 'julian_day.dart';
import 'solar_position.dart';
import 'lunar_position.dart';

/// Tithi (lunar day) calculations.
///
/// A Tithi is defined by every 12° of Moon-Sun angular separation.
/// 360° / 12° = 30 Tithis per lunar month.
class Tithi {
  Tithi._();

  /// Tithis 1–30 in Telugu (Shukla 1–15, then Krishna 1–15).
  static const List<String> namesTe = [
    'పాడ్యమి', 'విదియ', 'తదియ', 'చవితి', 'పంచమి',
    'షష్ఠి', 'సప్తమి', 'అష్టమి', 'నవమి', 'దశమి',
    'ఏకాదశి', 'ద్వాదశి', 'త్రయోదశి', 'చతుర్దశి', 'పౌర్ణమి',
    'పాడ్యమి', 'విదియ', 'తదియ', 'చవితి', 'పంచమి',
    'షష్ఠి', 'సప్తమి', 'అష్టమి', 'నవమి', 'దశమి',
    'ఏకాదశి', 'ద్వాదశి', 'త్రయోదశి', 'చతుర్దశి', 'అమావాస్య',
  ];

  /// Tithis 1–30 in English.
  static const List<String> namesEn = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima',
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasya',
  ];

  /// Moon-Sun angular separation in degrees (0–360°).
  static double moonSunDiff(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double sunLon = SolarPosition.siderealLongitude(jd);
    return JulianDay.normalize360(moonLon - sunLon);
  }

  /// Tithi number at a given Julian Day (1–30).
  static int number(double jd) {
    final double diff = moonSunDiff(jd);
    final int t = (diff / 12.0).floor() + 1;
    return t.clamp(1, 30);
  }

  /// Find the end time (IST) of the current Tithi at a given JD.
  /// The end time is when (Moon-Sun diff) crosses the next 12° boundary.
  static DateTime endTime(double jd) {
    final int tNum = number(jd);
    final double targetDiff = tNum * 12.0; // upper boundary in degrees

    // Estimate search window: each tithi ≈ 12° / 12.2°/day ≈ ~23.5 hours
    double lo = jd;
    double hi = jd + 1.5; // search up to 1.5 days ahead

    for (int i = 0; i < 60; i++) {
      final double mid = (lo + hi) / 2;
      final double diff = moonSunDiff(mid);

      bool pastBoundary;
      if (tNum == 30) {
        // Amavasya ends when diff wraps from 360° back to 0°
        pastBoundary = diff < 60.0; // diff has wrapped to near 0°
      } else {
        pastBoundary = diff >= targetDiff;
      }

      if (pastBoundary) {
        hi = mid;
      } else {
        lo = mid;
      }

      if ((hi - lo) * 86400 < 30) break; // 30-second precision
    }

    return JulianDay.toIST((lo + hi) / 2);
  }

  /// Paksha (lunar fortnight): 'Shukla' (tithis 1–15) or 'Krishna' (16–30).
  static String paksha(int tithiNumber) =>
      tithiNumber <= 15 ? 'Shukla' : 'Krishna';

  /// Telugu paksha name.
  static String pakshaTe(int tithiNumber) =>
      tithiNumber <= 15 ? 'శుక్ల పక్షం' : 'కృష్ణ పక్షం';

  /// Tithi number within the paksha (1–15) for display purposes.
  static int withinPaksha(int tithiNumber) =>
      tithiNumber <= 15 ? tithiNumber : tithiNumber - 15;
}
