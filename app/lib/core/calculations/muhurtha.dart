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

  /// Amrit Kalam — highly auspicious window derived from the day's Nakshatra.
  ///
  /// Source: Sringeri Panchangam (Visvavasu 2025-26), supervised by the Sringeri Matha.
  /// The Sringeri tradition distinguishes two types:
  ///   - Di.Amrita (దినామృతం): counted from SUNRISE — daytime window.
  ///   - Ra.Amrita (రాత్ర్యమృతం): counted from SUNSET — nighttime window.
  ///
  /// Duration: 4 ghatis = 96 minutes (standard). Sringeri shows ~106 min for some entries
  /// due to variable ghati length — 96 min is used for consistency (acceptable MVP delta).
  ///
  /// Only Sringeri-verified entries are populated. All others are null.
  /// Wrong data is worse than no data — unverified entries must stay null.
  ///
  /// Returns [start, end] as IST DateTimes, or null when no Amrit Kalam applies
  /// (either explicitly absent, or not yet verified from Sringeri PDF).
  static List<DateTime>? amritKalam(
    int nakshatraNumber,
    DateTime sunrise,
    DateTime sunset,
  ) {
    // Minutes from SUNRISE for Di.Amrita (daytime) entries.
    // null = not verified from Sringeri (treat as "not applicable" until confirmed).
    const List<int?> _dayOffset = [
      null, null, null, null, null, // 1-5:  Ashwini, Bharani, Krittika, Rohini, Mrigashirsha
      null, null, null, null, null, // 6-10: Ardra(S✓none), Punarvasu, Pushya, Ashlesha, Magha
      null, null, null, null, null, // 11-15: Purva Phalguni, Uttara Phalguni, Hasta, Chitra, Swati
      501,  null, null, null, null, // 16-20: Vishaka(S✓501min), Anuradha, Jyeshtha, Mula(night), PurvaAshadha(night)
      null, null, null, null, null, // 21-25: Uttara Ashadha, Shravana, Dhanishtha, Shatabhisha, Purva Bhadrapada
      null, null,                   // 26-27: Uttara Bhadrapada, Revati
    ];

    // Minutes from SUNSET for Ra.Amrita (nighttime) entries.
    // null = not verified from Sringeri (treat as "not applicable" until confirmed).
    const List<int?> _nightOffset = [
      null, null, null, null, null, // 1-5
      null, null, null, null, null, // 6-10: Ardra(S✓none)
      null, null, null, null, null, // 11-15
      null, null, null,  449,  682, // 16-20: Vishaka(day), Anuradha, Jyeshtha, Mula(S✓449min), PurvaAshadha(S✓682min)
      null, null, null, null, null, // 21-25
      null, null,                   // 26-27
    ];

    final int? day = _dayOffset[nakshatraNumber - 1];
    final int? night = _nightOffset[nakshatraNumber - 1];

    if (day != null) {
      final start = sunrise.add(Duration(minutes: day));
      return [start, start.add(const Duration(minutes: 96))];
    }
    if (night != null) {
      final start = sunset.add(Duration(minutes: night));
      return [start, start.add(const Duration(minutes: 96))];
    }
    return null;
  }
}
