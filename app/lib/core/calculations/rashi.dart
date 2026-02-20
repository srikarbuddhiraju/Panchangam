import 'lunar_position.dart';

/// Rashi (Moon sign) calculations.
///
/// The 12 Rashis divide the zodiac into 30° segments each.
/// Moon Rashi = which sign the Moon is currently in.
class Rashi {
  Rashi._();

  static const List<String> namesTe = [
    'మేషం', 'వృషభం', 'మిథునం', 'కర్కాటకం',
    'సింహం', 'కన్య', 'తుల', 'వృశ్చికం',
    'ధనస్సు', 'మకరం', 'కుంభం', 'మీనం',
  ];

  static const List<String> namesEn = [
    'Mesha (Aries)', 'Vrishabha (Taurus)', 'Mithuna (Gemini)',
    'Karkataka (Cancer)', 'Simha (Leo)', 'Kanya (Virgo)',
    'Tula (Libra)', 'Vrishchika (Scorpio)', 'Dhanus (Sagittarius)',
    'Makara (Capricorn)', 'Kumbha (Aquarius)', 'Meena (Pisces)',
  ];

  static const List<String> rulingPlanets = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter',
  ];

  /// Rashi number (1–12) from Moon's sidereal longitude.
  static int number(double jd) {
    final double moonLon = LunarPosition.siderealLongitude(jd);
    final int r = (moonLon / 30.0).floor() + 1;
    return r.clamp(1, 12);
  }

  /// Rashi number directly from Moon longitude (already computed).
  static int fromLongitude(double moonSiderealLon) {
    final int r = (moonSiderealLon / 30.0).floor() + 1;
    return r.clamp(1, 12);
  }
}
