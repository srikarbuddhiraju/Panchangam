/// Kalam (inauspicious period) timings.
///
/// Rahu Kalam, Gulika Kalam, and Yamaganda are each 1/8 of the day duration,
/// positioned at weekday-specific offsets from sunrise.
///
/// All periods are derived from sunrise and sunset times.
class KalamTimings {
  KalamTimings._();

  // Multipliers for each weekday (0=Sunday ... 6=Saturday)
  // Source: traditional Panchangam tables, confirmed against drikpanchang.com

  /// Rahu Kalam: period = day/8, start = sunrise + rahu * period
  static const List<int> rahuMultiplier = [7, 1, 6, 4, 5, 3, 2];

  /// Gulika Kalam: start = sunrise + gulika * period
  static const List<int> gulikaMultiplier = [6, 5, 4, 3, 2, 1, 0];

  /// Yamaganda: start = sunrise + yama * period
  static const List<int> yamagandaMultiplier = [3, 6, 2, 5, 1, 4, 7];

  /// Compute Rahu Kalam for a given vara and sunrise/sunset.
  /// Returns [start, end] IST DateTimes.
  static List<DateTime> rahuKalam(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    return _kalam(vara, sunrise, sunset, rahuMultiplier);
  }

  /// Compute Gulika Kalam for a given vara and sunrise/sunset.
  static List<DateTime> gulikaKalam(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    return _kalam(vara, sunrise, sunset, gulikaMultiplier);
  }

  /// Compute Yamaganda for a given vara and sunrise/sunset.
  static List<DateTime> yamaganda(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    return _kalam(vara, sunrise, sunset, yamagandaMultiplier);
  }

  static List<DateTime> _kalam(
    int vara,
    DateTime sunrise,
    DateTime sunset,
    List<int> multipliers,
  ) {
    final int daySeconds = sunset.difference(sunrise).inSeconds;
    final int periodSeconds = daySeconds ~/ 8;
    final int multiplier = multipliers[vara];

    final DateTime start =
        sunrise.add(Duration(seconds: multiplier * periodSeconds));
    final DateTime end = start.add(Duration(seconds: periodSeconds));
    return [start, end];
  }
}
