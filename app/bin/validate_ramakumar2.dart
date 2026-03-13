/// Validate Ramakumar formula accuracy — split by data period.
///
/// 2025-26 table (Apr–Nov) has known OCR data quality issues.
/// 2025-26 table (Dec–Mar) was carefully validated interactively.
/// 2026-27 table covers Mar 2026–Apr 2027 (carefully OCR'd).
///
/// Run: dart run bin/validate_ramakumar2.dart
library;

import 'package:panchangam/core/calculations/muhurtha.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/data/amrita_lookup.dart';

const double _lat = 16.5167;
const double _lng = 80.5000;

int bestError(String dateKey, (int, int) entry) {
  final parts = dateKey.split('-');
  final int y = int.parse(parts[0]);
  final int mo = int.parse(parts[1]);
  final int d = int.parse(parts[2]);
  final (int eh, int em) = entry;
  final DateTime expected = DateTime.utc(y, mo, d, eh, em);

  int? best;
  for (int delta = -1; delta <= 1; delta++) {
    final DateTime date = DateTime(y, mo, d).add(Duration(days: delta));
    final List<DateTime> ss = SunriseSunset.computeNOAA(date, _lat, _lng);
    final List<DateTime>? r = Muhurtha.amritKalamFormulaOnly(ss[0], lng: _lng);
    if (r != null) {
      int e = r[0].difference(expected).inMinutes.abs();
      final int wrapped = (24 * 60 - e).abs();
      if (wrapped < e) e = wrapped;
      if (best == null || e < best) best = e;
    }
  }
  return best ?? 9999;
}

void printStats(String label, List<int> errs) {
  final sorted = List.of(errs)..sort();
  final n = sorted.length;
  if (n == 0) { print('$label: no data'); return; }
  final w5 = sorted.where((e) => e <= 5).length;
  final w15 = sorted.where((e) => e <= 15).length;
  final w30 = sorted.where((e) => e <= 30).length;
  final w60 = sorted.where((e) => e <= 60).length;
  final mean = sorted.fold(0, (a, b) => a + b) / n;
  print('$label  (n=$n)');
  print('  ≤5min=${(w5/n*100).toStringAsFixed(1)}%  ≤15=${(w15/n*100).toStringAsFixed(1)}%  ≤30=${(w30/n*100).toStringAsFixed(1)}%  ≤60=${(w60/n*100).toStringAsFixed(1)}%  mean=${mean.toStringAsFixed(1)}m  median=${sorted[n~/2]}m');
}

void main() {
  final all = AmritaLookup.allEntries;

  final List<int> winterDec_Mar = []; // Dec 2025 – Mar 2026 (carefully OCR'd)
  final List<int> table2627 = [];     // 2026-27 table (Mar 2026 – Apr 2027)
  final List<int> other2526 = [];     // rest of 2025-26 (Apr–Nov 2025)
  int nullCount = 0;

  for (final e in all.entries) {
    final err = bestError(e.key, e.value);
    if (err == 9999) { nullCount++; continue; }

    final parts = e.key.split('-');
    final int y = int.parse(parts[0]);
    final int mo = int.parse(parts[1]);

    if (y == 2025 && mo == 12 ||
        y == 2026 && mo >= 1 && mo <= 3) {
      winterDec_Mar.add(err);
    } else if (y >= 2026 && e.key.compareTo('2026-03-19') >= 0) {
      table2627.add(err);
    } else {
      other2526.add(err);
    }
  }

  print('Formula null: $nullCount');
  print('');
  printStats('Dec 2025 – Mar 2026 (well-validated)', winterDec_Mar);
  print('');
  printStats('2026-27 table (Mar 2026 – Apr 2027)', table2627);
  print('');
  printStats('2025-26 table Apr–Nov (OCR quality issues)', other2526);
  print('');
  printStats('ALL entries', [...winterDec_Mar, ...table2627, ...other2526]);
}
