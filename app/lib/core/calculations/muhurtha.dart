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
  ///
  /// NOTE: Days 25-Feb (Rohini Wed) and 28-Feb (Punarvasu Sat) have BOTH Di and Ra
  /// Amrit windows. Only the Di value is stored here. Architecture upgrade needed to
  /// return multiple windows per day.
  ///
  /// NOTE: Hasta Fri entry 3.75 interpreted as 3.75 ghati decimal = 90 min (75 vipalas
  /// would be invalid). Krittika Tue 17.66 interpreted as 17×24+66×0.4=434 min.
  /// Both entries need recheck against original PDF.
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
    //
    // Source: Sringeri Panchangam Visvavasu 2025-26, full February 2026 (28 days).
    // Conversion: G.V notation → ghati×24 + vipala×0.4 = minutes.
    // All 27 nakshatras covered across 28 days (Vishaka appeared twice: Mon+Tue).
    // Additional verified entries:
    //   Ardra  Tue  Jan-27: 0    (అమృతఘటికాభావ confirmed)
    //   Pushya Sat  Mar-28: -144 (Ra 6gh00vi, validate output verified)
    const List<List<int?>> _amritTable = [
      //  Sun    Mon    Tue    Wed    Thu    Fri    Sat
      [   326,  null,  null,  null,  null,  null,  null], //  1 Ashwini    (Feb22 Sun Di13.36)
      [  null,   382,  null,  null,  null,  null,  null], //  2 Bharani    (Feb23 Mon Di15.55)
      [  null,  null,   434,  null,  null,  null,  null], //  3 Krittika   (Feb24 Tue Di17.66†)
      [  null,  null,  null,   274,  null,  null,  null], //  4 Rohini     (Feb25 Wed Di11.24; Ra25.11=604 also)
      [  null,  null,  null,  null,  -454,  null,  null], //  5 Mrigashirsha (Feb26 Thu Ra18.55)
      [  null,  null,     0,  null,  null,     0,  null], //  6 Ardra      (Jan27 Tue 0; Feb27 Fri 0)
      [  null,  null,  null,  null,  null,  null,    47], //  7 Punarvasu  (Feb28 Sat Di1.58; Ra20.25=490 also)
      [  -123,  null,  null,  null,  null,  null,  -144], //  8 Pushya     (Feb01 Sun Ra5.8; Mar28 Sat Ra6.00)
      [  null,  -258,  null,  null,  null,  null,  null], //  9 Ashlesha   (Feb02 Mon Ra10.46)
      [  null,  null,  -194,  null,  null,  null,  null], // 10 Magha      (Feb03 Tue Ra8.5)
      [  null,  null,  null,   626,  null,  null,  null], // 11 Purva Phalguni (Feb04 Wed Di26.6)
      [  null,  null,  null,  null,   648,  null,  null], // 12 Uttara Phalguni (Feb05 Thu Di26.59)
      [  null,  null,  null,  null,  null,   -90,  null], // 13 Hasta      (Feb06 Fri Ra3.75†)
      [  null,  null,  null,  null,  null,  null,  -153], // 14 Chitra     (Feb07 Sat Ra6.23)
      [  -116,  null,  null,  null,  null,  null,  null], // 15 Swati      (Feb08 Sun Ra4.50)
      [  null,  -254,  -289,  null,  null,  null,  null], // 16 Vishaka    (Feb09 Mon Ra10.35; Feb10 Tue Ra12.2)
      [  null,  null,  null,  -574,  null,  null,  null], // 17 Anuradha   (Feb11 Wed Ra23.55)
      [  null,  null,  null,  null,     0,  null,  null], // 18 Jyeshtha   (Feb12 Thu 0 confirmed)
      [  null,  null,  null,  null,  null,   116,  null], // 19 Mula       (Feb13 Fri Di4.51)
      [  null,  null,  null,  null,  null,  null,   354], // 20 Purva Ashadha (Feb14 Sat Di14.46)
      [   362,  null,  null,  null,  null,  null,  null], // 21 Uttara Ashadha (Feb15 Sun Di15.4)
      [  null,   193,  null,  null,  null,  null,  null], // 22 Shravana   (Feb16 Mon Di8.3)
      [  null,  null,   256,  null,  null,  null,  null], // 23 Dhanishtha  (Feb17 Tue Di10.39)
      [  null,  null,  null,   383,  null,  null,  null], // 24 Shatabhisha (Feb18 Wed Di15.57)
      [  null,  null,  null,  null,   428,  null,  null], // 25 Purva Bhadrapada (Feb19 Thu Di17.50)
      [  null,  null,  null,  null,  null,   586,  null], // 26 Uttara Bhadrapada (Feb20 Fri Di24.25)
      [  null,  null,  null,  null,  null,  null,   673], // 27 Revati     (Feb21 Sat Di28.2)
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
