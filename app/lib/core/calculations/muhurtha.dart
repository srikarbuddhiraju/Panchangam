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
  /// Timing varies by Nakshatra; this implementation uses the hora-based offset.
  /// Each hora = sunrise + (nakshatraNumber * 3) hours, duration = 48 minutes.
  ///
  /// Note: For exact traditional values, a full hora table is needed.
  /// This gives an approximate Amrit Kalam window.
  ///
  /// Returns [start, end] as IST DateTimes.
  static List<DateTime> amritKalam(
    int nakshatraNumber,
    DateTime sunrise,
    DateTime sunset,
  ) {
    // Amrit Kalam starts at a Nakshatra-specific hora
    // These offsets (in 20-minute units from sunrise) are approximate
    // based on the traditional Amrit Yoga hour assignment table
    const List<int> horaOffsets = [
      // Nakshatra 1–27 → offset in minutes from sunrise
      480, 440, 400, 360, 320, // 1-5
      280, 240, 200, 160, 120, // 6-10
      80, 40, 0, 480, 440,    // 11-15
      400, 360, 320, 280, 240, // 16-20
      200, 160, 120, 80, 40,  // 21-25
      0, 480,                  // 26-27
    ];

    final int offsetMinutes = horaOffsets[nakshatraNumber - 1];
    final int daySeconds = sunset.difference(sunrise).inSeconds;

    // If offset exceeds day duration, wrap around next day
    final int offsetSeconds = offsetMinutes * 60;
    final DateTime start = sunrise.add(Duration(seconds: offsetSeconds % daySeconds));
    final DateTime end = start.add(const Duration(minutes: 48));

    return [start, end];
  }
}
