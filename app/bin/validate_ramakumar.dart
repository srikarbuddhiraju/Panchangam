/// Validate Ramakumar formula accuracy against all Sringeri lookup table entries.
///
/// For every date in _table2526 + _table2627 (~464 entries):
///   1. Compute Ramakumar formula result for Kondavidu sunrise on that date.
///   2. Also try sunrise of next day (pre-dawn Ra.Amrita entries in Sringeri are
///      listed under the calendar day they fall in, but belong to the prior
///      panchangam night — formula run for previous sunrise captures these).
///   3. Compare against the stored Sringeri time, take the minimum error.
///   4. Record error in minutes.
///
/// Both expected and formula result are compared as UTC-tagged DateTimes
/// (the project convention: IST values stored in UTC-tagged DateTime objects).
///
/// Reports: % within 5/15/30 min, mean absolute error, worst 20 cases.
///
/// Run: dart run bin/validate_ramakumar.dart
library;

import 'package:panchangam/core/calculations/muhurtha.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/data/amrita_lookup.dart';

const double _lat = 16.5167; // Kondavidu latitude
const double _lng = 80.5000; // Kondavidu longitude

void main() {
  final Map<String, (int, int)> all = AmritaLookup.allEntries;
  print('Total lookup entries: ${all.length}');
  print('');

  final List<(String, int)> errors = []; // (date, errorMin)
  int formulaNull = 0;

  for (final entry in all.entries) {
    final parts = entry.key.split('-');
    final int y = int.parse(parts[0]);
    final int mo = int.parse(parts[1]);
    final int d = int.parse(parts[2]);
    final DateTime date = DateTime(y, mo, d);

    // Expected: UTC-tagged DateTime with IST values (project convention).
    final (int eh, int em) = entry.value;
    final DateTime expected = DateTime.utc(y, mo, d, eh, em);

    // Try formula for prev/current/next day sunrise.
    // Sringeri assigns amrit to the calendar date it falls in, which can differ
    // from the panchangam day (sunrise-to-sunrise). Trying ±1 day handles:
    //   - Pre-dawn Ra.Amrita (early AM, belongs to prev panchangam night)
    //   - Post-midnight amrit that falls on a different calendar day
    int? best;
    for (int delta = -1; delta <= 1; delta++) {
      final DateTime d2 = date.add(Duration(days: delta));
      final List<DateTime> ss2 = SunriseSunset.computeNOAA(d2, _lat, _lng);
      final List<DateTime>? r = Muhurtha.amritKalamFormulaOnly(ss2[0], lng: _lng);
      if (r != null) {
        int e = r[0].difference(expected).inMinutes.abs();
        // Also try wrapping ±24h for near-midnight boundary cases where the
        // formula and Sringeri table are on different calendar sides of midnight.
        final int wrapped = (24 * 60 - e).abs();
        if (wrapped < e) e = wrapped;
        if (best == null || e < best) best = e;
      }
    }

    if (best == null) {
      formulaNull++;
      errors.add((entry.key, 9999));
    } else {
      errors.add((entry.key, best));
    }
  }

  // ── Statistics ──────────────────────────────────────────────────────────────
  final List<int> realErrors =
      errors.where((e) => e.$2 != 9999).map((e) => e.$2).toList()..sort();
  final int n = realErrors.length;

  if (n == 0) {
    print('No valid comparisons. formulaNull=$formulaNull');
    return;
  }

  final int within5 = realErrors.where((e) => e <= 5).length;
  final int within15 = realErrors.where((e) => e <= 15).length;
  final int within30 = realErrors.where((e) => e <= 30).length;
  final int within60 = realErrors.where((e) => e <= 60).length;
  final double mean = realErrors.fold(0, (a, b) => a + b) / n;

  print('── Summary ───────────────────────────────────────────────');
  print('Entries compared : $n / ${all.length}');
  print('Formula null     : $formulaNull');
  print('');
  print('Within  5 min : ${within5.toString().padLeft(3)} / $n  '
      '(${(within5 / n * 100).toStringAsFixed(1)}%)');
  print('Within 15 min : ${within15.toString().padLeft(3)} / $n  '
      '(${(within15 / n * 100).toStringAsFixed(1)}%)');
  print('Within 30 min : ${within30.toString().padLeft(3)} / $n  '
      '(${(within30 / n * 100).toStringAsFixed(1)}%)');
  print('Within 60 min : ${within60.toString().padLeft(3)} / $n  '
      '(${(within60 / n * 100).toStringAsFixed(1)}%)');
  print('Mean abs error: ${mean.toStringAsFixed(1)} min');
  print('Median error  : ${realErrors[n ~/ 2]} min');
  print('');

  // ── Worst cases ─────────────────────────────────────────────────────────────
  final List<(String, int)> sorted = List.of(errors)
    ..sort((a, b) => b.$2.compareTo(a.$2));
  print('── Worst 20 cases ────────────────────────────────────────');
  print('${'Date'.padRight(12)} ${'Formula'.padRight(8)} ${'Expected'.padRight(8)} Error');
  int shown = 0;
  for (final (String dateKey, int err) in sorted) {
    if (shown >= 20) break;
    shown++;
    final parts2 = dateKey.split('-');
    final int y2 = int.parse(parts2[0]);
    final int mo2 = int.parse(parts2[1]);
    final int d2 = int.parse(parts2[2]);
    final DateTime date2 = DateTime(y2, mo2, d2);

    // Recompute to show formula time.
    final List<DateTime> ss2 =
        SunriseSunset.computeNOAA(date2, _lat, _lng);
    final List<DateTime>? r1b =
        Muhurtha.amritKalamFormulaOnly(ss2[0], lng: _lng);
    final List<DateTime> ssN =
        SunriseSunset.computeNOAA(date2.add(const Duration(days: 1)), _lat, _lng);
    final List<DateTime>? r2b =
        Muhurtha.amritKalamFormulaOnly(ssN[0], lng: _lng);
    final (int eh2, int em2) = all[dateKey]!;
    final DateTime exp2 = DateTime.utc(y2, mo2, d2, eh2, em2);

    String formulaStr = 'null';
    int? bestErr;
    DateTime? bestResult;
    for (final r in [r1b, r2b]) {
      if (r != null) {
        final int e = r[0].difference(exp2).inMinutes.abs();
        if (bestErr == null || e < bestErr) {
          bestErr = e;
          bestResult = r[0];
        }
      }
    }
    if (bestResult != null) {
      formulaStr =
          '${bestResult.hour.toString().padLeft(2, '0')}:${bestResult.minute.toString().padLeft(2, '0')}';
    }

    final String expStr =
        '${eh2.toString().padLeft(2, '0')}:${em2.toString().padLeft(2, '0')}';
    final String errStr = err == 9999 ? 'NULL' : '${err}m';
    print('$dateKey  $formulaStr  $expStr  $errStr');
  }

  // ── Error distribution ───────────────────────────────────────────────────────
  print('');
  print('── Error distribution ────────────────────────────────────');
  final bands = [5, 15, 30, 60, 120, 9998];
  int prev = 0;
  for (final band in bands) {
    final int count =
        realErrors.where((e) => e > prev && e <= band).length;
    final label = band == 9998 ? '>120' : '${prev + 1}–$band';
    print('  ${'$label min'.padRight(12)}: $count');
    prev = band;
  }
}
