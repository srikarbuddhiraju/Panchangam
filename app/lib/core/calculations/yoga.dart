import 'julian_day.dart';
import 'solar_position.dart';
import 'lunar_position.dart';

/// Yoga calculations.
///
/// Yoga = floor((Sun longitude + Moon longitude) mod 360 / 13.333°) + 1
/// There are 27 Yogas, each spanning 13°20'.
class Yoga {
  Yoga._();

  static const double _yogaSpan = 360.0 / 27; // 13.3333°

  static const List<String> namesTe = [
    'విష్కంభ', 'ప్రీతి', 'ఆయుష్మాన్', 'సౌభాగ్య', 'శోభన',
    'అతిగండ', 'సుకర్మ', 'ధృతి', 'శూల', 'గండ',
    'వృద్ధి', 'ధ్రువ', 'వ్యాఘాత', 'హర్షణ', 'వజ్ర',
    'సిద్ధి', 'వ్యతీపాత', 'వరీయాన్', 'పరిఘ', 'శివ',
    'సిద్ధ', 'సాధ్య', 'శుభ', 'శుక్ల', 'బ్రహ్మ',
    'ఇంద్ర', 'వైధృతి',
  ];

  static const List<String> namesEn = [
    'Vishkambha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shoola', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyana', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti',
  ];

  /// true = auspicious, false = inauspicious
  static const List<bool> isAuspicious = [
    false, true, true, true, true,  // 1-5
    false, true, true, false, false, // 6-10
    true, true, false, true, true,  // 11-15 (Vajra = mixed → true)
    true, false, true, false, true, // 16-20
    true, true, true, true, true,   // 21-25
    true, false,                    // 26-27 (Vaidhriti = inauspicious)
  ];

  /// Sun+Moon combined longitude (0–360°).
  static double sunMoonSum(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double sunLon = SolarPosition.siderealLongitude(jd);
    return JulianDay.normalize360(moonLon + sunLon);
  }

  /// Yoga number at a given Julian Day (1–27).
  static int number(double jd) {
    final double sum = sunMoonSum(jd);
    final int y = (sum / _yogaSpan).floor() + 1;
    return y.clamp(1, 27);
  }

  /// Find the end time (IST) of the current Yoga.
  /// Sun+Moon combined moves at ~13.18 + 0.98 ≈ 14.16°/day.
  static DateTime endTime(double jd) {
    final int yNum = number(jd);
    final double targetSum = yNum * _yogaSpan;

    double lo = jd;
    double hi = jd + 1.5;

    for (int i = 0; i < 60; i++) {
      final double mid = (lo + hi) / 2;
      final double sum = sunMoonSum(mid);

      bool pastBoundary;
      if (yNum == 27) {
        pastBoundary = sum < 30.0;
      } else {
        pastBoundary = sum >= targetSum;
      }

      if (pastBoundary) {
        hi = mid;
      } else {
        lo = mid;
      }

      if ((hi - lo) * 86400 < 30) break;
    }

    return JulianDay.toIST((lo + hi) / 2);
  }
}
