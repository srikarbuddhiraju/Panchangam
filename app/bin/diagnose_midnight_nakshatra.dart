/// Diagnoses whether Sringeri uses MIDNIGHT as the nakshatra reference time
/// instead of sunrise.
///
/// Hypothesis: for Dec08/10/11 (and similar dates), our Moon is in the NEXT
/// nakshatra at sunrise, but in the Sringeri nakshatra at midnight.
/// If confirmed → switch nakshatra lookup to midnight in panchangam_engine.
///
/// Run: dart run bin/diagnose_midnight_nakshatra.dart
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 12.9716; // Bengaluru
const double lng = 77.5946;
const double nkSpan = 360.0 / 27;

/// Nakshatra name (1-based number → name)
const List<String> nkNames = [
  '', // 0 unused
  'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
  'PurvaPhalguni', 'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati',
  'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'PurvaAshadha',
  'UttaraAshadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
  'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

class TestCase {
  final String label;
  final DateTime date;
  final int sringeriNk; // Sringeri's reported nakshatra number (1-based)
  final String sringeriAmrita; // Sringeri's amrita time (IST)
  const TestCase(this.label, this.date, this.sringeriNk, this.sringeriAmrita);
}

final cases = [
  TestCase('Dec08 Mon', DateTime(2025, 12, 8), 7, '07:04'), // Punarvasu
  TestCase('Dec10 Wed', DateTime(2025, 12, 10), 9, '07:48'), // Ashlesha
  TestCase('Dec11 Thu', DateTime(2025, 12, 11), 10, '07:13'), // Magha
  // Control cases (no mismatch expected)
  TestCase('Dec17 Wed', DateTime(2025, 12, 17), 16, '07:45'), // Vishakha OK
  TestCase('Jan25 Sun', DateTime(2026, 1, 25), 27, '09:54'), // Revati OK
  TestCase('Feb09 Mon', DateTime(2026, 2, 9), 16, '22:30'), // Vishakha OK
  TestCase('Feb10 Tue', DateTime(2026, 2, 10), 16, '23:08'), // Vishakha — MISS on device
  TestCase('Jan26 Mon', DateTime(2026, 1, 26), 1, '04:53'), // Ashwini — MISS
];

void main() {
  print('Midnight Nakshatra Hypothesis Diagnostic');
  print('Location: Bengaluru (${lat}°N, ${lng}°E)');
  print('');
  print('For each date: nakshatra computed at MIDNIGHT vs SUNRISE vs PREV-MIDNIGHT');
  print('Sringeri NK = the nakshatra printed in Sringeri Panchangam for that day');
  print('');

  final hdr = '${'Date'.padRight(10)}  ${'Sringeri NK'.padRight(16)}  '
      '${'NK@Midnight'.padRight(16)}  ${'NK@Sunrise'.padRight(16)}  '
      '${'NK@PrevMidnight'.padRight(16)}  Match?';
  print(hdr);
  print('─' * hdr.length);

  int midnightMatches = 0;
  int sunriseMatches = 0;
  int prevMidnightMatches = 0;

  for (final c in cases) {
    final sunTimes = SunriseSunset.computeNOAA(c.date, lat, lng);
    final sunrise = sunTimes[0];

    // Three reference times to test:
    // 1. Today's midnight (00:00 IST)
    final DateTime todayMidnight = DateTime(c.date.year, c.date.month, c.date.day, 0, 0);
    // 2. Sunrise
    // 3. Previous midnight (00:00 IST of previous day)
    final DateTime prevDay = c.date.subtract(const Duration(days: 1));
    final DateTime prevMidnight = DateTime(prevDay.year, prevDay.month, prevDay.day, 0, 0);

    final double jdMidnight = JulianDay.fromIST(todayMidnight);
    final double jdSunrise = JulianDay.fromIST(sunrise);
    final double jdPrevMidnight = JulianDay.fromIST(prevMidnight);

    final double lonMidnight = LunarPosition.siderealLongitude(jdMidnight);
    final double lonSunrise = LunarPosition.siderealLongitude(jdSunrise);
    final double lonPrevMidnight = LunarPosition.siderealLongitude(jdPrevMidnight);

    final int nkMidnight = ((lonMidnight / nkSpan).floor() % 27) + 1;
    final int nkSunrise = ((lonSunrise / nkSpan).floor() % 27) + 1;
    final int nkPrevMidnight = ((lonPrevMidnight / nkSpan).floor() % 27) + 1;

    final bool midnightMatch = nkMidnight == c.sringeriNk;
    final bool sunriseMatch = nkSunrise == c.sringeriNk;
    final bool prevMidnightMatch = nkPrevMidnight == c.sringeriNk;

    if (midnightMatch) midnightMatches++;
    if (sunriseMatch) sunriseMatches++;
    if (prevMidnightMatch) prevMidnightMatches++;

    final String matchStr = midnightMatch
        ? 'MIDNIGHT ✓'
        : sunriseMatch
            ? 'SUNRISE ✓'
            : prevMidnightMatch
                ? 'PREV-MIDNIGHT ✓'
                : 'NONE (mismatch)';

    print('${c.label.padRight(10)}  '
        '${c.sringeriNk.toString().padLeft(2)} ${nkNames[c.sringeriNk].padRight(13)}  '
        '${nkMidnight.toString().padLeft(2)} ${nkNames[nkMidnight].padRight(13)}  '
        '${nkSunrise.toString().padLeft(2)} ${nkNames[nkSunrise].padRight(13)}  '
        '${nkPrevMidnight.toString().padLeft(2)} ${nkNames[nkPrevMidnight].padRight(13)}  '
        '$matchStr');
  }

  print('');
  print('Summary: Midnight matches ${midnightMatches}/${cases.length}, '
      'Sunrise matches ${sunriseMatches}/${cases.length}, '
      'PrevMidnight matches ${prevMidnightMatches}/${cases.length}');

  print('');
  print('─── Moon longitude detail ───────────────────────────────────────────');
  print('');
  for (final c in cases) {
    final sunTimes = SunriseSunset.computeNOAA(c.date, lat, lng);
    final sunrise = sunTimes[0];
    final DateTime todayMidnight = DateTime(c.date.year, c.date.month, c.date.day, 0, 0);

    final double jdMidnight = JulianDay.fromIST(todayMidnight);
    final double jdSunrise = JulianDay.fromIST(sunrise);

    final double lonMidnight = LunarPosition.siderealLongitude(jdMidnight);
    final double lonSunrise = LunarPosition.siderealLongitude(jdSunrise);

    final int nkMidnight = ((lonMidnight / nkSpan).floor() % 27) + 1;
    final int nkSunrise = ((lonSunrise / nkSpan).floor() % 27) + 1;

    final double fracMidnight = (lonMidnight % nkSpan) / nkSpan * 100;
    final double fracSunrise = (lonSunrise % nkSpan) / nkSpan * 100;

    print('${c.label}: sunrise=${_fmt(sunrise)}');
    print('  Moon@midnight : ${lonMidnight.toStringAsFixed(3)}°  '
        '→ NK${nkMidnight} ${nkNames[nkMidnight]} ${fracMidnight.toStringAsFixed(1)}%');
    print('  Moon@sunrise  : ${lonSunrise.toStringAsFixed(3)}°  '
        '→ NK${nkSunrise} ${nkNames[nkSunrise]} ${fracSunrise.toStringAsFixed(1)}%');
    print('  Sringeri NK   : NK${c.sringeriNk} ${nkNames[c.sringeriNk]}  amrita=${c.sringeriAmrita}');
    print('');
  }
}

String _fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} IST';
