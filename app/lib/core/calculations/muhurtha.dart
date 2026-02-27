/// Muhurtha (auspicious/inauspicious window) calculations.
///
/// A Muhurtha is 1/30 of the day (sidereal day ÷ 30 = ~48 minutes).
/// For Panchangam purposes, we use daylight period ÷ 15 per half-day convention.
class Muhurtha {
  Muhurtha._();

  /// Abhijit Muhurtha — the most auspicious window of the day.
  ///
  /// Centered on solar noon. Duration: 24 minutes before + 24 minutes after.
  /// NOT valid on Wednesdays (vara == 3).
  ///
  /// Returns [start, end] as IST DateTimes, or null for Wednesday.
  static List<DateTime>? abhijit(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    if (vara == 3) return null; // Wednesday — Abhijit not auspicious

    final int halfDaySeconds = sunset.difference(sunrise).inSeconds ~/ 2;
    final DateTime solarNoon = sunrise.add(Duration(seconds: halfDaySeconds));

    final DateTime start = solarNoon.subtract(const Duration(minutes: 24));
    final DateTime end = solarNoon.add(const Duration(minutes: 24));
    return [start, end];
  }

  /// Dur Muhurta — inauspicious period(s) each day.
  ///
  /// Each Dur Muhurta period = 1 muhurtha = dayDuration/15.
  /// Positions are weekday-specific (1-indexed muhurtha of the 15 daytime muhurthas).
  ///
  /// Returns list of [start, end] pairs.
  static List<List<DateTime>> durMuhurta(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    // Each muhurtha = daylight duration / 15
    final int daySeconds = sunset.difference(sunrise).inSeconds;
    final int muhurthaSeconds = daySeconds ~/ 15;

    // Weekday-specific Dur Muhurtha positions (1-indexed, one per day)
    // Based on traditional Panchangam tables
    const List<int> durPositions = [
      8,  // Sunday: 8th muhurtha
      7,  // Monday: 7th muhurtha
      7,  // Tuesday: 7th muhurtha
      2,  // Wednesday: 2nd muhurtha (special)
      10, // Thursday: 10th muhurtha
      7,  // Friday: 7th muhurtha
      9,  // Saturday: 9th muhurtha
    ];

    final int pos = durPositions[vara];
    // Convert 1-indexed position to seconds from sunrise
    final DateTime start =
        sunrise.add(Duration(seconds: (pos - 1) * muhurthaSeconds));
    final DateTime end = start.add(Duration(seconds: muhurthaSeconds));

    return [
      [start, end]
    ];
  }

  /// Amrit Kalam — highly auspicious window keyed on Nakshatra × Weekday (vara).
  ///
  /// Source: Sringeri Panchangam (Visvavasu 2025-26), supervised by the Sringeri Matha.
  /// The same nakshatra gives Di.Amrita on some weekdays and Ra.Amrita on others —
  /// the type is NOT fixed per nakshatra alone. A 27×7 lookup table is required.
  ///
  ///   - Di.Amrita (దినామృతం): offset from SUNRISE — stored as positive minutes.
  ///   - Ra.Amrita (రాత్ర్యమృతం): offset from SUNSET — stored as negative minutes.
  ///   - 0    = confirmed అమృతఘటికాభావ (no amrit kalam) for this nakshatra+vara.
  ///   - null = not yet verified from Sringeri PDF (shown as "Not applicable").
  ///
  /// Duration: 4 ghatis = 96 minutes (standard).
  /// Wrong data is worse than no data — unverified cells stay null.
  ///
  /// [vara]: weekday 0=Sunday … 6=Saturday (matches Vara.number / Vara.fromDateTime).
  ///
  /// Returns [start, end] as IST DateTimes, or null when not applicable.
  static List<DateTime>? amritKalam(
    int nakshatraNumber,
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    // 27×7 table — rows: nakshatra 1-27 (index 0-26),
    //              cols: vara 0-6 (Sunday=0 … Saturday=6).
    // Encoding: null=unverified, 0=confirmed none, +N=Di.Amrita N min from sunrise,
    //           -N=Ra.Amrita N min from sunset.
    // Source dates (Sringeri Panchangam, Visvavasu 2025-26):
    //   Ardra  Tue  Jan-27: 0    (అమృతఘటికాభావ confirmed)
    //   Pushya Sat  Feb-01: -144 (Ra 6gh00vi)
    //   Ashlesha Sun Feb-02: -146 (Ra 6gh05vi)
    //   Magha  Mon  Feb-03: -194 (Ra 8gh05vi)
    //   PurvaP Wed  Feb-04: 626  (Di 26gh04vi)
    //   UttaraP Thu Feb-05: -628 (Ra 26gh09vi)
    //   Hasta  Fri  Feb-06: -80  (Ra back-calc from Ra||7:25; source unclear — needs recheck)
    //   Chitra Sat  Feb-07: -147 (Ra 6gh07vi)
    //   Swati  Sun  Feb-08: -147 (Ra 6gh07vi)
    //   Vishaka Mon Feb-09: -254 (Ra 10gh35vi)
    //   Vishaka Tue Jan-13: 501  (Di 20gh53vi)
    //   Jyeshtha Thu: contradictory data (Jan-15 gives -143, Feb-12 gives 0) — left null
    const List<List<int?>> _amritTable = [
      //  Sun    Mon    Tue    Wed    Thu    Fri    Sat
      [  null,  null,  null,  null,  null,  null,  null], //  1 Ashwini
      [  null,  null,  null,  null,  null,  null,  null], //  2 Bharani
      [  null,  null,  null,  null,  null,  null,  null], //  3 Krittika
      [  null,  null,  null,  null,  null,  null,  null], //  4 Rohini
      [  null,  null,  null,  null,  null,  null,  null], //  5 Mrigashirsha
      [  null,  null,     0,  null,  null,  null,  null], //  6 Ardra
      [  null,  null,  null,  null,  null,  null,  null], //  7 Punarvasu
      [  null,  null,  null,  null,  null,  null,  -144], //  8 Pushya
      [  -146,  null,  null,  null,  null,  null,  null], //  9 Ashlesha
      [  null,  -194,  null,  null,  null,  null,  null], // 10 Magha
      [  null,  null,  null,   626,  null,  null,  null], // 11 Purva Phalguni
      [  null,  null,  null,  null,  -628,  null,  null], // 12 Uttara Phalguni
      [  null,  null,  null,  null,  null,   -80,  null], // 13 Hasta (needs recheck)
      [  null,  null,  null,  null,  null,  null,  -147], // 14 Chitra
      [  -147,  null,  null,  null,  null,  null,  null], // 15 Swati
      [  null,  -254,   501,  null,  null,  null,  null], // 16 Vishaka
      [  null,  null,  null,  null,  null,  null,  null], // 17 Anuradha
      [  null,  null,  null,  null,  null,  null,  null], // 18 Jyeshtha (contradictory)
      [  null,  null,  null,  null,  null,  null,  null], // 19 Mula
      [  null,  null,  null,  null,  null,  null,  null], // 20 Purva Ashadha
      [  null,  null,  null,  null,  null,  null,  null], // 21 Uttara Ashadha
      [  null,  null,  null,  null,  null,  null,  null], // 22 Shravana
      [  null,  null,  null,  null,  null,  null,  null], // 23 Dhanishtha
      [  null,  null,  null,  null,  null,  null,  null], // 24 Shatabhisha
      [  null,  null,  null,  null,  null,  null,  null], // 25 Purva Bhadrapada
      [  null,  null,  null,  null,  null,  null,  null], // 26 Uttara Bhadrapada
      [  null,  null,  null,  null,  null,  null,  null], // 27 Revati
    ];

    final int? v = _amritTable[nakshatraNumber - 1][vara];
    if (v == null || v == 0) return null;

    if (v > 0) {
      // Di.Amrita — offset from sunrise
      final start = sunrise.add(Duration(minutes: v));
      return [start, start.add(const Duration(minutes: 96))];
    } else {
      // Ra.Amrita — offset from sunset
      final start = sunset.add(Duration(minutes: -v));
      return [start, start.add(const Duration(minutes: 96))];
    }
  }
}
