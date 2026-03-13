/// Diagnostic script for 900+ minute boundary errors in Amrita Kalam.
///
/// Investigates 5 dates where the formula returns times ~15-22h after sunrise
/// instead of the expected early-morning Sringeri reference time.
///
/// Hypothesis: At sunrise, Moon is near the END of the nakshatra (past the
/// _amritFrac target). Code falls through to attempt 2 (next nakshatra after
/// transition), finding a time ~18-24h later.
///
/// Run: dart run bin/diagnose_boundary_errors.dart
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';

const double lat = 17.3850;
const double lng = 78.4867;
const double nkSpan = 360.0 / 27; // 13.333°

/// _amritFrac table (0-based index, mirrors muhurtha.dart)
const List<double?> amritFrac = [
  0.67, //  0 Ashwini
  0.78, //  1 Bharani
  0.91, //  2 Krittika
  0.91, //  3 Rohini
  0.63, //  4 Mrigashirsha
  0.54, //  5 Ardra
  0.90, //  6 Punarvasu
  0.80, //  7 Pushya
  0.98, //  8 Ashlesha
  0.96, //  9 Magha
  0.85, // 10 Purva Phalguni
  0.82, // 11 Uttara Phalguni
  0.82, // 12 Hasta
  0.82, // 13 Chitra
  0.70, // 14 Swati
  0.65, // 15 Vishaka
  0.59, // 16 Anuradha
  0.60, // 17 Jyeshtha
  0.68, // 18 Mula
  0.75, // 19 Purva Ashadha
  0.68, // 20 Uttara Ashadha
  0.53, // 21 Shravana
  0.54, // 22 Dhanishtha
  0.69, // 23 Shatabhisha
  0.68, // 24 Purva Bhadrapada
  0.84, // 25 Uttara Bhadrapada
  0.84, // 26 Revati
];

const List<String> nkNames = [
  'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
  'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
  'Vishaka', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
  'Uttara Ashadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
  'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
];

String fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

String fmtLon(double lon) => lon.toStringAsFixed(4).padLeft(10);

void diagnose(String label, DateTime date, String sringeriRef) {
  print('');
  print('=' * 70);
  print('DATE: $label  |  Sringeri ref: $sringeriRef');
  print('=' * 70);

  final times = SunriseSunset.computeNOAA(date, lat, lng);
  final DateTime sunrise = times[0];
  final double jdSunrise = JulianDay.fromIST(sunrise);

  print('Sunrise IST:     ${fmt(sunrise)}  (JD=${ jdSunrise.toStringAsFixed(6)})');

  // ── Attempt 0: state at sunrise ────────────────────────────────────────────
  final double moonLonSr = LunarPosition.siderealLongitude(jdSunrise);
  final int nkIdxSr = (moonLonSr / nkSpan).floor() % 27;
  final double? fracSr = amritFrac[nkIdxSr];
  final double targetLonSr = nkIdxSr * nkSpan + (fracSr ?? 0.5) * nkSpan;
  final double fracThruNk = (moonLonSr - nkIdxSr * nkSpan) / nkSpan;

  print('');
  print('--- AT SUNRISE ---');
  print('Moon lon:        ${fmtLon(moonLonSr)}°');
  print('Nakshatra idx:   $nkIdxSr  →  ${nkNames[nkIdxSr]}  (Nakshatra.number=${nkIdxSr+1})');
  print('_amritFrac:      ${fracSr ?? "null"}');
  print('Target lon:      ${fmtLon(targetLonSr)}°  (nkIdx*span + frac*span)');
  print('Moon fraction:   ${(fracThruNk * 100).toStringAsFixed(1)}% through nakshatra');

  final bool pastAtSunrise = moonLonSr >= targetLonSr;
  print('Status:          ${pastAtSunrise ? "*** PAST TARGET at sunrise ***" : "before target at sunrise"}');

  // ── Nakshatra.number() check (1-based, same as public API) ─────────────────
  final int nkNumPublic = Nakshatra.number(jdSunrise);
  print('Nakshatra.number(jdSunrise): $nkNumPublic  (${nkNames[nkNumPublic - 1]})');

  // ── Nakshatra end time ─────────────────────────────────────────────────────
  final DateTime nkEnd = Nakshatra.endTime(jdSunrise);
  final double jdNkEnd = JulianDay.fromIST(nkEnd);
  final int minToEnd = nkEnd.difference(sunrise).inMinutes;
  print('Nakshatra ends:  ${fmt(nkEnd)}  (${minToEnd} min after sunrise)');

  // ── Attempt 1: state at nakshatra end time ─────────────────────────────────
  print('');
  print('--- AT NAKSHATRA END (attempt 2 search point) ---');
  final double moonLonEnd = LunarPosition.siderealLongitude(jdNkEnd);
  final int nkIdxEnd = (moonLonEnd / nkSpan).floor() % 27;
  final double? fracEnd = amritFrac[nkIdxEnd];
  final double targetLonEnd = nkIdxEnd * nkSpan + (fracEnd ?? 0.5) * nkSpan;
  final double fracThruNkEnd = (moonLonEnd - nkIdxEnd * nkSpan) / nkSpan;
  final bool pastAtEnd = moonLonEnd >= targetLonEnd;

  print('Moon lon at end: ${fmtLon(moonLonEnd)}°');
  print('Nakshatra idx:   $nkIdxEnd  →  ${nkNames[nkIdxEnd]}');
  print('_amritFrac:      ${fracEnd ?? "null"}');
  print('Target lon:      ${fmtLon(targetLonEnd)}°');
  print('Moon fraction:   ${(fracThruNkEnd * 100).toStringAsFixed(1)}% through nakshatra');
  print('Status:          ${pastAtEnd ? "*** PAST TARGET at nkEnd ***" : "before target at nkEnd"}');

  // ── Estimate when Moon will reach the attempt-2 target ────────────────────
  if (!pastAtEnd) {
    // Moon speed ~0.549°/h
    final double degToGo = targetLonEnd - moonLonEnd;
    final double hoursToTarget = degToGo / 0.549;
    final DateTime estimated = nkEnd.add(Duration(minutes: (hoursToTarget * 60).round()));
    final int minFromSunrise = estimated.difference(sunrise).inMinutes;
    print('Est. amrita start: ${fmt(estimated)}  (~${minFromSunrise} min after sunrise)');
  }

  print('');
}

void main() {
  print('Amrita Kalam Boundary Error Diagnosis');
  print('Hyderabad: lat=$lat, lng=$lng');
  print('Purpose: Show why formula returns times 900-1348 min after sunrise');
  print('for dates where Sringeri shows early-morning (Di) amrita kalam.');

  diagnose('Dec 08 2025 Mon Punarvasu Di', DateTime(2025, 12,  8), '07:04');
  diagnose('Dec 10 2025 Wed Ashlesha  Di', DateTime(2025, 12, 10), '07:48');
  diagnose('Dec 11 2025 Thu Magha     Di', DateTime(2025, 12, 11), '07:13');
  diagnose('Dec 15 2025 Mon Chitra    Di', DateTime(2025, 12, 15), '07:35');
  diagnose('Dec 16 2025 Tue Swati     Di', DateTime(2025, 12, 16), '07:31');

  print('');
  print('=' * 70);
  print('SUMMARY');
  print('=' * 70);
  print('Dates where Moon is PAST the _amritFrac target at sunrise:');
  print('  → attempt 1 skips (continue), attempt 2 finds next-nk target');
  print('  → next-nk target may be 18-24h later → 900-1348 min error');
  print('');
  print('Root cause: These are "boundary" days where:');
  print('  1. Moon is very deep into the nakshatra at sunrise (>_amritFrac)');
  print('  2. The actual Sringeri amrita is in the next ~15-60 min (Di = day)');
  print('     but still BEFORE the official nakshatra end.');
  print('  3. The formula misses this because moonLon >= targetLon at sunrise,');
  print('     so it skips to attempt 2 (next nakshatra transition).');
  print('');
  print('Fix approach: When moonLon >= targetLon at sunrise but nkEnd is');
  print('  within ~2h of sunrise, check if Sringeri intends amrita to be');
  print('  between sunrise and nkEnd (i.e., the fraction used for boundary');
  print('  days should be 1.0 → amrita at nkEnd itself, or we need a');
  print('  separate "boundary day" frac override).');
}
