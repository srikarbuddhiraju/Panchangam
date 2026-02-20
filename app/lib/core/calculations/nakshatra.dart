import 'julian_day.dart';
import 'lunar_position.dart';

/// Nakshatra (lunar mansion) calculations.
///
/// The sky is divided into 27 equal segments of 13°20' (13.333°) each.
/// The Nakshatra is determined by the Moon's sidereal longitude.
class Nakshatra {
  Nakshatra._();

  static const double _nakshatraSpan = 360.0 / 27; // 13.3333°

  /// Nakshatra names in Telugu (1–27).
  static const List<String> namesTe = [
    'అశ్వని', 'భరణి', 'కృత్తిక', 'రోహిణి', 'మృగశిర',
    'ఆర్ద్ర', 'పునర్వసు', 'పుష్యమి', 'ఆశ్లేష', 'మఖ',
    'పుబ్బ', 'ఉత్తర', 'హస్త', 'చిత్త', 'స్వాతి',
    'విశాఖ', 'అనూరాధ', 'జ్యేష్ఠ', 'మూల', 'పూర్వాషాఢ',
    'ఉత్తరాషాఢ', 'శ్రవణం', 'ధనిష్ఠ', 'శతభిషం', 'పూర్వాభాద్ర',
    'ఉత్తరాభాద్ర', 'రేవతి',
  ];

  /// Nakshatra names in English (1–27).
  static const List<String> namesEn = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushyami', 'Ashlesha', 'Makha',
    'Pubba', 'Uttara', 'Hasta', 'Chitra', 'Swati',
    'Vishakha', 'Anuradha', 'Jyeshtha', 'Moola', 'Purvashadha',
    'Uttarashadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
    'Purvabhadra', 'Uttarabhadra', 'Revati',
  ];

  /// Ruling planets for each Nakshatra (for display).
  static const List<String> rulers = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars',
    'Rahu', 'Jupiter', 'Saturn', 'Mercury', 'Ketu',
    'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus',
    'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter',
    'Saturn', 'Mercury',
  ];

  /// Nakshatra number at a given Julian Day (1–27).
  static int number(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final int n = (moonLon / _nakshatraSpan).floor() + 1;
    return n.clamp(1, 27);
  }

  /// Pada (quarter, 1–4) of the current Nakshatra.
  static int pada(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final double intoNakshatra = moonLon % _nakshatraSpan;
    return (intoNakshatra / (_nakshatraSpan / 4)).floor() + 1;
  }

  /// Find the end time (IST) of the current Nakshatra.
  /// Ends when Moon's sidereal longitude crosses the next 13.333° boundary.
  static DateTime endTime(double jd) {
    final int nNum = number(jd);
    final double targetLon = nNum * _nakshatraSpan; // upper boundary

    // Moon moves ~13.18°/day, so each Nakshatra lasts ~27/27.3 days ≈ 23.9 hours
    double lo = jd;
    double hi = jd + 1.5;

    for (int i = 0; i < 60; i++) {
      final double mid = (lo + hi) / 2;
      final double moonLon = LunarPosition.siderealLongitude(mid);

      bool pastBoundary;
      if (nNum == 27) {
        // Revati ends when moon longitude wraps from 360° to 0°
        pastBoundary = moonLon < 30.0;
      } else {
        pastBoundary = moonLon >= targetLon;
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
