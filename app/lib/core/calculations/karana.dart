import 'julian_day.dart';
import 'tithi.dart';

/// Karana (half-tithi) calculations.
///
/// A Karana = half a Tithi = 6° of Moon-Sun separation.
/// 60 Karanas per lunar month: 56 repeating + 4 fixed.
///
/// Sequence within month (1–60):
///   Seq 1–56: cycle through 7 repeating Karanas
///   Seq 57: Shakuni (fixed)
///   Seq 58: Chatushpada (fixed)
///   Seq 59: Naga (fixed)
///   Seq 60: Kimstughna (fixed)
class Karana {
  Karana._();

  /// 7 repeating Karanas (index 0–6).
  static const List<String> repeatNamesTe = [
    'బవ', 'బాలవ', 'కౌలవ', 'తైతిల', 'గరజ', 'వణిజ', 'విష్టి (భద్ర)',
  ];
  static const List<String> repeatNamesEn = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Garaja', 'Vanija', 'Vishti',
  ];

  /// 4 fixed Karanas at end of month (index 0–3 = seq 57–60).
  static const List<String> fixedNamesTe = [
    'శకుని', 'చతుష్పాద', 'నాగ', 'కింస్తుఘ్న',
  ];
  static const List<String> fixedNamesEn = [
    'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna',
  ];

  /// Karana number (1–11) at a given Julian Day.
  /// 1–7 = repeating, 8 = Shakuni, 9 = Chatushpada, 10 = Naga, 11 = Kimstughna.
  static int number(double jd) {
    final int t = Tithi.number(jd);
    final double diff = Tithi.moonSunDiff(jd);
    final double excessInTithi = diff - (t - 1) * 12.0;
    final int half = excessInTithi < 6.0 ? 1 : 2;

    final int seq = (t - 1) * 2 + half; // 1–60

    // Seq 1 = Kimstughna (fixed, opens every lunar month)
    // Seq 2–57 = 8 full cycles of the 7 movable karanas
    // Seq 58 = Shakuni, 59 = Chatushpada, 60 = Naga (fixed, close the month)
    if (seq == 1) return 11;                    // Kimstughna
    if (seq <= 57) return (seq - 2) % 7 + 1;   // movable 1–7
    return 7 + (seq - 57);                      // 8=Shakuni, 9=Chatushpada, 10=Naga
  }

  /// Telugu name for a Karana number (1–11).
  static String nameTe(int karanaNumber) {
    if (karanaNumber <= 7) return repeatNamesTe[karanaNumber - 1];
    return fixedNamesTe[karanaNumber - 8];
  }

  /// English name for a Karana number (1–11).
  static String nameEn(int karanaNumber) {
    if (karanaNumber <= 7) return repeatNamesEn[karanaNumber - 1];
    return fixedNamesEn[karanaNumber - 8];
  }

  /// Is this Karana inauspicious? (Vishti/Bhadra = #7 is the main one).
  static bool isInauspicious(int karanaNumber) => karanaNumber == 7;

  /// Find the end time (IST) of the current Karana (when diff crosses next 6° boundary).
  static DateTime endTime(double jd) {
    final int t = Tithi.number(jd);
    final double diff = Tithi.moonSunDiff(jd);
    final double excessInTithi = diff - (t - 1) * 12.0;
    final int half = excessInTithi < 6.0 ? 1 : 2;

    // Target: the diff value at the end of this karana half
    final double targetDiff = (t - 1) * 12.0 + half * 6.0; // 6, 12, 18, ...

    double lo = jd;
    double hi = jd + 0.75; // Karana ≤ ~14 hours

    for (int i = 0; i < 60; i++) {
      final double mid = (lo + hi) / 2;
      final double midDiff = Tithi.moonSunDiff(mid);

      bool pastBoundary;
      if (targetDiff >= 360.0) {
        pastBoundary = midDiff < 60.0; // wrapped
      } else {
        pastBoundary = midDiff >= targetDiff;
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
