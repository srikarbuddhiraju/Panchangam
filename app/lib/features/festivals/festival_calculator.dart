import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../core/calculations/julian_day.dart';
import '../../core/calculations/sunrise_sunset.dart';
import 'festival_data.dart';

/// Computes Gregorian dates of festivals for a given year.
///
/// For Tithi-based festivals: scans each day and checks if the
/// Tithi matches at sunrise (Telugu tradition — Tithi at sunrise).
///
/// For solar festivals: uses the fixed Gregorian date.
class FestivalCalculator {
  FestivalCalculator._();

  static const double _hyderabadLat = 17.3850;
  static const double _hyderabadLng = 78.4867;

  /// Compute a map of [date → list of festival names] for a given year.
  ///
  /// [lat]/[lng] — location for sunrise calculation. Defaults to Hyderabad.
  static Map<DateTime, List<Festival>> computeYear(
    int year, {
    double lat = _hyderabadLat,
    double lng = _hyderabadLng,
  }) {
    final Map<DateTime, List<Festival>> result = {};

    // Scan each day of the year
    for (int month = 1; month <= 12; month++) {
      final int daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final DateTime date = DateTime(year, month, day);
        final List<Festival> onThisDay = _festivalsOnDate(date, lat, lng);

        if (onThisDay.isNotEmpty) {
          result[date] = onThisDay;
        }
      }
    }

    return result;
  }

  static List<Festival> _festivalsOnDate(
    DateTime date,
    double lat,
    double lng,
  ) {
    final List<Festival> found = [];

    for (final festival in FestivalData.all) {
      if (festival.type == FestivalType.solar) {
        if (festival.gregorianMonth == date.month &&
            festival.gregorianDay == date.day) {
          found.add(festival);
        }
      } else {
        // Tithi-based: check Tithi at sunrise (daytime festivals)
        // or at 11:30 PM (night-observed festivals like Shivaratri, Janmashtami)
        if (_isTithiMatch(date, festival, lat, lng)) {
          found.add(festival);
        }
      }
    }

    return found;
  }

  static bool _isTithiMatch(
    DateTime date,
    Festival festival,
    double lat,
    double lng,
  ) {
    if (festival.tithi == null || festival.paksha == null) return false;

    try {
      // For night-observed festivals (Shivaratri, Janmashtami etc.):
      // check the tithi at 11:30 PM IST of this date, not at sunrise.
      // This assigns the festival to the night it is actually observed.
      final double jdCheck;
      if (festival.observedAtNight) {
        // 11:30 PM IST = 18:00 UTC on same calendar date
        final DateTime nightTime =
            DateTime(date.year, date.month, date.day, 18, 0); // UTC
        jdCheck = JulianDay.fromIST(nightTime);
      } else {
        final List<DateTime> sunTimes =
            SunriseSunset.computeNOAA(date, lat, lng);
        jdCheck = JulianDay.fromIST(sunTimes[0]);
      }

      final int tNum = Tithi.number(jdCheck);
      final int tPaksha = tNum <= 15 ? 1 : 2; // 1=Shukla, 2=Krishna
      final int tWithinPaksha = tNum <= 15 ? tNum : tNum - 15;

      // Amavasya in Krishna Paksha is tithi 15 (the 30th overall)
      // In festival_data.dart, Krishna Amavasya is stored as paksha=2, tithi=15
      if (tPaksha == festival.paksha && tWithinPaksha == festival.tithi) {
        if (festival.teluguMonth != null) {
          // Festivals never fall in Adhika months
          if (TeluguCalendar.isAdhikaMaasa(jdCheck)) return false;
          final int teluguMonth = TeluguCalendar.monthNumber(jdCheck);
          return teluguMonth == festival.teluguMonth;
        }
        return true;
      }

      // ── Kshaya Pratipada handling ──────────────────────────────────────────
      // When Pratipada is a kshaya tithi it doesn't appear at any sunrise.
      // Traditional rule: Ugadi falls on the Amavasya day itself, because
      // Pratipada BEGINS that same day (after sunrise) before the next day's
      // sunrise arrives.
      //
      // Detection: today's sunrise = Amavasya(30) AND tomorrow's sunrise = Vidiya(2).
      // We use tomorrow's JD for the month check — on the Amavasya day the
      // month is still the old Phalguna (12), but tomorrow is firmly Chaitra (1).
      if (festival.paksha == 1 && festival.tithi == 1 && tNum == 30) {
        final DateTime nextDate = date.add(const Duration(days: 1));
        final List<DateTime> nextSun =
            SunriseSunset.computeNOAA(nextDate, lat, lng);
        final double nextJd = JulianDay.fromIST(nextSun[0]);
        if (Tithi.number(nextJd) == 2) {
          if (festival.teluguMonth != null) {
            if (TeluguCalendar.isAdhikaMaasa(nextJd)) return false;
            return TeluguCalendar.monthNumber(nextJd) == festival.teluguMonth;
          }
          return true;
        }
      }
    } catch (_) {
      // Ignore calculation errors for edge cases
    }
    return false;
  }
}
