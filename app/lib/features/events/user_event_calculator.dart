import '../../core/calculations/panchangam_engine.dart';
import 'user_tithi_event.dart';

/// Determines which user tithi events fall on a given calendar day.
///
/// Matching rules (mirrors the logic of FestivalCalculator for tithi festivals):
/// - Event's [tithi] must match [DayData.tithiNumber] (1–30)
/// - If event's [teluguMonth] is null → recurs every paksha (matched twice a month)
/// - If event's [teluguMonth] is set → recurs once a year in that Telugu month
/// - Events are never shown on adhika maasa days (same rule as built-in festivals)
/// - Inactive events are always excluded
class UserEventCalculator {
  UserEventCalculator._();

  /// Return names of all active user events that match [day].
  ///
  /// Returns an empty list if no events match (never throws).
  static List<String> namesForDay(
    List<UserTithiEvent> events,
    DayData day,
  ) {
    if (events.isEmpty) return const [];
    if (day.isAdhikaMaasa) return const [];

    final List<String> matched = [];
    for (final event in events) {
      if (_matches(event, day)) {
        matched.add(event.nameEn);
      }
    }
    return matched;
  }

  static bool _matches(UserTithiEvent event, DayData day) {
    if (!event.isActive) return false;
    if (event.tithi != day.tithiNumber) return false;
    if (event.teluguMonth != null &&
        event.teluguMonth != day.teluguMonthNumber) return false;
    return true;
  }
}
