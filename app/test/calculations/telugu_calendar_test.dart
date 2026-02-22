import 'package:flutter_test/flutter_test.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/telugu_calendar.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/features/festivals/festival_calculator.dart';

// Hyderabad
const double _lat = 17.3850;
const double _lng = 78.4867;

double _jdAtSunrise(DateTime date) {
  final times = SunriseSunset.computeNOAA(date, _lat, _lng);
  return JulianDay.fromIST(times[0]);
}

void main() {
  // ── monthNumber() — key property tests ────────────────────────────────────
  group('monthNumber', () {
    test('Mid-Chaitra (Apr 5 2026) → Chaitra (1), not Vaisakha', () {
      // The old solar approximation returned 2 (Vaisakha) for dates after
      // Mesha Sankranti (~Apr 14) even while the lunar month is still Chaitra.
      // New next-Amavasya method correctly returns 1 for the whole month.
      final jd = _jdAtSunrise(DateTime(2026, 4, 5));
      expect(TeluguCalendar.monthNumber(jd), equals(1));
    });

    test('Ugadi day (Mar 19 2026) is the Phalguna Amavasya → month 12', () {
      // March 19 = Phalguna Amavasya = last day of Phalguna month (12).
      // Chaitra starts the next day. monthNumber correctly returns 12 here.
      final jd = _jdAtSunrise(DateTime(2026, 3, 19));
      expect(TeluguCalendar.monthNumber(jd), equals(12));
    });

    test('Mar 20 2026 (Chaitra Vidiya after kshaya Pratipada) → Chaitra (1)', () {
      final jd = _jdAtSunrise(DateTime(2026, 3, 20));
      expect(TeluguCalendar.monthNumber(jd), equals(1));
    });

    test('Feb 15 2026 → Magha (11)', () {
      // Feb 15 is in Magha; the next Amavasya (Feb 17) has sun in Kumbha.
      final jd = _jdAtSunrise(DateTime(2026, 2, 15));
      expect(TeluguCalendar.monthNumber(jd), equals(11));
    });

    test('Month number stays in range 1–12 throughout 2026', () {
      for (int doy = 0; doy < 365; doy += 10) {
        final date = DateTime(2026, 1, 1).add(Duration(days: doy));
        final jd = _jdAtSunrise(date);
        final m = TeluguCalendar.monthNumber(jd);
        expect(m, inInclusiveRange(1, 12),
            reason: 'Got month $m for $date');
      }
    });
  });

  // ── isAdhikaMaasa() ───────────────────────────────────────────────────────
  group('isAdhikaMaasa', () {
    test('2026 has exactly one adhika period (Adhika Vaisakha ≈ May–Jun)', () {
      // Two consecutive new moons fall in Vrishabha in 2026 → Adhika Vaisakha.
      // Adhika period: May 17 – Jun 15 (the month with no Sankranti inside it).
      // Nija Vaisakha is the preceding month (Apr 17 – May 16) which contains
      // the Vrishabha Sankranti around May 14–15.
      final adhikaDays = <DateTime>[];
      for (int doy = 0; doy < 365; doy += 1) {
        final date = DateTime(2026, 1, 1).add(Duration(days: doy));
        final jd = _jdAtSunrise(date);
        if (TeluguCalendar.isAdhikaMaasa(jd)) adhikaDays.add(date);
      }
      expect(adhikaDays.length, inInclusiveRange(25, 35),
          reason:
              'Expected ~29 adhika days in 2026, got ${adhikaDays.length}. '
              'First: ${adhikaDays.firstOrNull}, last: ${adhikaDays.lastOrNull}');
      // All adhika days should be Vaisakha (month 2)
      for (final date in adhikaDays) {
        final jd = _jdAtSunrise(date);
        expect(TeluguCalendar.monthNumber(jd), equals(2),
            reason:
                'Adhika 2026 should be Vaisakha(2), got '
                '${TeluguCalendar.monthNumber(jd)} on $date');
      }
    });

    test('2023 has exactly one adhika period (Adhika Ashadha ≈ Jul–Aug)', () {
      // Jul 17 Amavasya: sun at 90.7° sidereal (Karka/Cancer).
      // Aug 16 Amavasya: sun at 119.1° sidereal (still Karka).
      // Both Amavasyas fall in Karka → Adhika Ashadha (month 4).
      // Adhika period: Jul 17 – Aug 16 (the month with no Sankranti inside it).
      // The preceding month Jun 19 – Jul 17 contains the Karka Sankranti (~Jul 16)
      // so it is the Nija Ashadha (regular month).
      // Note: some external calendars label this "Adhika Shravana" using a
      // slightly different ayanamsha that places Jul 17 at <90° (Mithuna).
      // Our Lahiri-based calculation consistently returns month 4 (Ashadha).
      final adhikaDays = <DateTime>[];
      for (int doy = 0; doy < 365; doy += 1) {
        final date = DateTime(2023, 1, 1).add(Duration(days: doy));
        final jd = _jdAtSunrise(date);
        if (TeluguCalendar.isAdhikaMaasa(jd)) adhikaDays.add(date);
      }
      expect(adhikaDays.length, inInclusiveRange(25, 35),
          reason:
              'Expected ~29 adhika days in 2023, got ${adhikaDays.length}');
      // All adhika days should be Ashadha (month 4)
      for (final date in adhikaDays) {
        final jd = _jdAtSunrise(date);
        expect(TeluguCalendar.monthNumber(jd), equals(4),
            reason:
                'Adhika 2023 should be Ashadha(4), got '
                '${TeluguCalendar.monthNumber(jd)} on $date');
      }
    });

    test('2025 has no adhika month', () {
      for (int doy = 0; doy < 365; doy += 5) {
        final date = DateTime(2025, 1, 1).add(Duration(days: doy));
        final jd = _jdAtSunrise(date);
        expect(TeluguCalendar.isAdhikaMaasa(jd), isFalse,
            reason: 'Unexpected adhika on $date in 2025');
      }
    });
  });

  // ── Ugadi 2026 festival detection ─────────────────────────────────────────
  group('Ugadi 2026', () {
    test('Ugadi falls on March 19 2026 (kshaya Pratipada case)', () {
      // March 19 sunrise = Amavasya(30), March 20 sunrise = Vidiya(2).
      // Pratipada is kshaya — begins March 19 after sunrise.
      // Correct traditional rule: Ugadi = March 19.
      final festivals =
          FestivalCalculator.computeYear(2026, lat: _lat, lng: _lng);

      final ugadiEntries = festivals.entries
          .where((e) => e.value.any((f) => f.nameEn == 'Ugadi'))
          .toList();

      expect(ugadiEntries.length, equals(1),
          reason: 'Expected exactly one Ugadi date in 2026');

      final date = ugadiEntries.first.key;
      expect(date.month, equals(3), reason: 'Ugadi should be in March');
      expect(date.day, equals(19),
          reason:
              'Ugadi 2026 should be March 19, got ${date.month}/${date.day}');
    });

    test('March 20 2026 is NOT Ugadi', () {
      final festivals =
          FestivalCalculator.computeYear(2026, lat: _lat, lng: _lng);
      final onMarch20 = festivals[DateTime(2026, 3, 20)] ?? [];
      expect(onMarch20.any((f) => f.nameEn == 'Ugadi'), isFalse,
          reason: 'March 20 is Vidiya day — Ugadi must not appear here');
    });

    test('Festivals in Adhika Vaisakha 2026 are suppressed', () {
      // Akshaya Tritiya (Vaisakha Shukla 3) must NOT appear in the adhika period
      // (May 17 – Jun 15); it should appear only in Nija Vaisakha (Apr 17 – May 16).
      // With the correct isAdhikaMaasa() logic, Nija Vaisakha comes BEFORE the
      // adhika month, so Akshaya Tritiya falls in April (~Apr 20).
      final festivals =
          FestivalCalculator.computeYear(2026, lat: _lat, lng: _lng);
      final aksharyas = festivals.entries
          .where((e) => e.value.any((f) => f.nameEn == 'Akshaya Tritiya'))
          .toList();

      expect(aksharyas.length, equals(1),
          reason: 'Akshaya Tritiya should appear exactly once (in Nija Vaisakha)');

      // Nija Vaisakha is Apr 17 – May 16, so Akshaya Tritiya must be in April.
      // It must NOT fall in May 17 – Jun 15 (the Adhika Vaisakha period).
      final akshDate = aksharyas.first.key;
      expect(akshDate.month, equals(4),
          reason:
              'Akshaya Tritiya must be in Nija Vaisakha (April). '
              'Got $akshDate');
    });
  });
}
