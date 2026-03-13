/// Builds the 27×7 Amrita table from all 124 reference entries.
///
/// Groups by (nakshatra, weekday). For duplicate (nk, vara) cells,
/// shows all values and flags inconsistency if spread > 20 min.
///
/// Run: dart run bin/build_amrit_table.dart
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 12.9716;
const double lng = 77.5946;

const nkNames = [
  '', 'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'PurvaPhalguni',
  'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
  'Jyeshtha', 'Mula', 'PurvaAshadha', 'UttaraAshadha', 'Shravana',
  'Dhanishtha', 'Shatabhisha', 'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

const varaNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class E {
  final String lbl;
  final DateTime date;
  final int nk;
  final int v;
  final int off;
  E(this.lbl, this.date, this.nk, this.v, this.off);
}

final entries = [
  // Exact entries from validate_amrita_formula.dart
  // ── December 2025 ─────────────────────────────────────────────────────────
  E('Dec01 Mon Revati  Di', DateTime(2025,12, 1), 27, 1,  660),
  E('Dec02 Tue Ashwini Di', DateTime(2025,12, 2),  1, 2,  305),
  E('Dec03 Wed Bharani Di', DateTime(2025,12, 3),  2, 3,  348),
  E('Dec04 Thu Krttika Di', DateTime(2025,12, 4),  3, 4,  383),
  E('Dec05 Fri Rohini  Di', DateTime(2025,12, 5),  4, 5,  238),
  E('Dec06 Sat Mrgshr  Ra', DateTime(2025,12, 6),  5, 6, -446),
  E('Dec08 Mon Pnrvsu  Di', DateTime(2025,12, 8),  7, 1,   30),
  E('Dec10 Wed Ashlsh  Di', DateTime(2025,12,10),  9, 3,   73),
  E('Dec11 Thu Magha   Di', DateTime(2025,12,11), 10, 4,   37),
  E('Dec12 Fri PvPhg   Ra', DateTime(2025,12,12), 11, 5, -495),
  E('Dec13 Sat UtPhg   Ra', DateTime(2025,12,13), 12, 6, -649),
  E('Dec14 Sun Hasta   Ra', DateTime(2025,12,14), 13, 0, -722),
  E('Dec15 Mon Chitra  Di', DateTime(2025,12,15), 14, 1,   57),
  E('Dec16 Tue Swati   Di', DateTime(2025,12,16), 15, 2,   31),
  E('Dec17 Wed Vishka  Di', DateTime(2025,12,17), 16, 3,   71),
  E('Dec18 Thu Anrdha  Di', DateTime(2025,12,18), 17, 4,  119),
  // ── January 2026 ──────────────────────────────────────────────────────────
  E('Jan02 Fri Mrgshr  Di', DateTime(2026, 1, 2),  5, 5,  305),
  E('Jan05 Mon Pushya  Di', DateTime(2026, 1, 5),  8, 1,  216),
  E('Jan07 Wed Magha   Di', DateTime(2026, 1, 7), 10, 3,  401),
  E('Jan08 Thu PvPhg   Di', DateTime(2026, 1, 8), 11, 4,  175),
  E('Jan09 Fri UtPhg   Di', DateTime(2026, 1, 9), 12, 5,  169),
  E('Jan10 Sat Hasta   Di', DateTime(2026, 1,10), 13, 6,  315),
  E('Jan11 Sun Chitra  Di', DateTime(2026, 1,11), 14, 0,  390),
  E('Jan12 Mon Swati   Di', DateTime(2026, 1,12), 15, 1,  358),
  E('Jan13 Tue Vishka  Di', DateTime(2026, 1,13), 16, 2,  503),
  E('Jan14 Wed Anrdha  Di', DateTime(2026, 1,14), 17, 3,  546),
  E('Jan15 Thu Jystha  Ra', DateTime(2026, 1,15), 18, 4, -130),
  E('Jan20 Tue Shrvan  Ra', DateTime(2026, 1,20), 22, 2, -545),
  E('Jan25 Sun Revati  Di', DateTime(2026, 1,25), 27, 0,  183),
  E('Jan26 Mon Ashwni  Ra', DateTime(2026, 1,26),  1, 1, -636),
  E('Jan29 Thu Mrgshr  Ra', DateTime(2026, 1,29),  5, 4, -113),
  E('Jan30 Fri Ardra   Di', DateTime(2026, 1,30),  6, 5,  634),
  E('Jan31 Sat Pnrvsu  Ra', DateTime(2026, 1,31),  7, 6, -301),
  E('Feb01 Sun Pushya  Ra', DateTime(2026, 2, 1),  8, 0,   -8),
  E('Feb02 Mon Ashlsh  Ra', DateTime(2026, 2, 2),  9, 1, -244),
  E('Feb03 Tue Magha   Ra', DateTime(2026, 2, 3), 10, 2, -179),
  E('Feb04 Wed PvPhg   Di', DateTime(2026, 2, 4), 11, 3,  633),
  E('Feb05 Thu UtPhg   Di', DateTime(2026, 2, 5), 12, 4,  618),
  E('Feb06 Fri Hasta   Ra', DateTime(2026, 2, 6), 13, 5,  -71),
  E('Feb07 Sat Chitra  Ra', DateTime(2026, 2, 7), 14, 6, -138),
  E('Feb08 Sun Swati   Ra', DateTime(2026, 2, 8), 15, 0, -101),
  E('Feb09 Mon Vishka  Ra', DateTime(2026, 2, 9), 16, 1, -238),
  E('Feb10 Tue Vishka  Ra', DateTime(2026, 2,10), 16, 2, -285),
  E('Feb11 Wed Anrdha  Ra', DateTime(2026, 2,11), 17, 3, -546),
  E('Feb13 Fri Mula    Di', DateTime(2026, 2,13), 19, 5,  106),
  E('Feb14 Sat PvAsh   Di', DateTime(2026, 2,14), 20, 6,  344),
  E('Feb15 Sun UtAsh   Di', DateTime(2026, 2,15), 21, 0,  352),
  E('Feb16 Mon Shrvan  Di', DateTime(2026, 2,16), 22, 1,  183),
  E('Feb17 Tue Dhnsth  Di', DateTime(2026, 2,17), 23, 2,  247),
  E('Feb18 Wed Shtbsh  Di', DateTime(2026, 2,18), 24, 3,  469),
  E('Feb19 Thu PvBhd   Di', DateTime(2026, 2,19), 25, 4,  418),
  E('Feb20 Fri UtBhd   Di', DateTime(2026, 2,20), 26, 5,  579),
  E('Feb21 Sat Revati  Di', DateTime(2026, 2,21), 27, 6,  663),
  E('Feb22 Sun Ashwni  Di', DateTime(2026, 2,22),  1, 0,  317),
  E('Feb23 Mon Bharni  Di', DateTime(2026, 2,23),  2, 1,  368),
  E('Feb24 Tue Krttka  Di', DateTime(2026, 2,24),  3, 2,  409),
  E('Feb25 Wed Rohini  Di', DateTime(2026, 2,25),  4, 3,  265),
  E('Feb26 Thu Mrgshr  Ra', DateTime(2026, 2,26),  5, 4, -426),
  E('Feb28 Sat Pnrvsu  Di', DateTime(2026, 2,28),  7, 6,   38),
  // ── March 2026 ────────────────────────────────────────────────────────────
  E('Mar10 Tue Anrdha  Di', DateTime(2026, 3,10), 17, 2,   92),
  E('Mar11 Wed Jystha  Di', DateTime(2026, 3,11), 18, 3,  248),
  E('Mar12 Thu Mula    Di', DateTime(2026, 3,12), 19, 4,  560),
  E('Mar13 Fri PvAsh   Ra', DateTime(2026, 3,13), 20, 5,  -95),
  E('Mar14 Sat UtAsh   Ra', DateTime(2026, 3,14), 21, 6, -104),
  E('Mar15 Sun Shrvan  Di', DateTime(2026, 3,15), 22, 0,  656),
  E('Mar16 Mon Dhnsth  Ra', DateTime(2026, 3,16), 23, 1,   -8),
  E('Mar17 Tue Shtbsh  Ra', DateTime(2026, 3,17), 24, 2, -218),
  E('Mar18 Wed PvBhd   Ra', DateTime(2026, 3,18), 25, 3, -194),
  E('Mar19 Thu UtBhd   Ra', DateTime(2026, 3,19), 26, 4, -358),
  // ── April 2025 ────────────────────────────────────────────────────────────
  E('Apr01 Tue Bharni  Di', DateTime(2025, 4, 1),  2, 2,  266),
  E('Apr02 Wed Krttka  Di', DateTime(2025, 4, 2),  3, 3,  306),
  E('Apr03 Thu Rohini  Di', DateTime(2025, 4, 3),  4, 4,  176),
  E('Apr03 Thu Mrgshr  Ra', DateTime(2025, 4, 3),  5, 4, -488),
  E('Apr04 Fri Mrgshr  Ra', DateTime(2025, 4, 4),  5, 5, -362),
  E('Apr06 Sun Pnrvsu  Di', DateTime(2025, 4, 6),  7, 0,   71),
  E('Apr06 Sun Pushya  Ra', DateTime(2025, 4, 6),  8, 0, -530),
  E('Apr08 Tue Ashlsh  Di', DateTime(2025, 4, 8),  9, 2,  144),
  E('Apr09 Wed Magha   Di', DateTime(2025, 4, 9), 10, 3,  152),
  E('Apr09 Wed Magha   Ra', DateTime(2025, 4, 9), 10, 3, -682),
  E('Apr11 Fri UtPhg   Di', DateTime(2025, 4,11), 12, 5,   40),
  E('Apr12 Sat Hasta   Di', DateTime(2025, 4,12), 13, 6,  250),
  E('Apr13 Sun Chitra  Di', DateTime(2025, 4,13), 14, 0,  371),
  E('Apr14 Mon Swati   Di', DateTime(2025, 4,14), 15, 1,  368),
  E('Apr15 Tue Vishka  Di', DateTime(2025, 4,15), 16, 2,  523),
  E('Apr17 Thu Jystha  Ra', DateTime(2025, 4,17), 18, 4,  -46),
  E('Apr18 Fri Jystha  Ra', DateTime(2025, 4,18), 18, 5, -300),
  E('Apr19 Sat Mula    Ra', DateTime(2025, 4,19), 19, 6, -468),
  E('Apr20 Sun PvAsh   Ra', DateTime(2025, 4,20), 20, 0, -407),
  E('Apr21 Mon UtAsh   Ra', DateTime(2025, 4,21), 21, 1, -175),
  E('Apr22 Tue Shrvan  Ra', DateTime(2025, 4,22), 22, 2, -161),
  E('Apr23 Wed Dhnsth  Ra', DateTime(2025, 4,23), 23, 3, -309),
  E('Apr24 Thu Shtbsh  Ra', DateTime(2025, 4,24), 24, 4, -202),
  E('Apr25 Fri PvBhd   Ra', DateTime(2025, 4,25), 25, 5, -304),
  E('Apr26 Sat UtBhd   Ra', DateTime(2025, 4,26), 26, 6, -346),
  E('Apr27 Sun Ashwni  Di', DateTime(2025, 4,27),  1, 0,  733),
  E('Apr28 Mon Bharni  Ra', DateTime(2025, 4,28),  2, 1,  -12),
  E('Apr29 Tue Krttka  Ra', DateTime(2025, 4,29),  3, 2,  -50),
  E('Apr30 Wed Rohini  Di', DateTime(2025, 4,30),  4, 3,  673),
  // ── August 2025 ──────────────────────────────────────────────────────────
  E('Aug01 Fri Swati   Di', DateTime(2025, 8, 1), 15, 5,  677),
  E('Aug02 Sat Vishka  Di', DateTime(2025, 8, 2), 16, 6,  314),
  E('Aug03 Sun Vishka  Ra', DateTime(2025, 8, 3), 16, 0, -121),
  E('Aug04 Mon Anrdha  Ra', DateTime(2025, 8, 3), 17, 0, -371),
  E('Aug05 Tue Jystha  Ra', DateTime(2025, 8, 4), 18, 1, -649),
  E('Aug06 Wed Mula    Di', DateTime(2025, 8, 6), 19, 3,  272),
  E('Aug07 Thu PvAsh   Ra', DateTime(2025, 8, 6), 20, 3, -483),
  E('Aug08 Fri UtAsh   Di', DateTime(2025, 8, 8), 21, 5,  127),
  E('Aug09 Sat Shrvan  Ra', DateTime(2025, 8, 8), 22, 5, -613),
  E('Aug11 Mon Shtbsh  Di', DateTime(2025, 8,11), 24, 1,  103),
  E('Aug12 Tue PvBhd   Ra', DateTime(2025, 8,12), 25, 2, -270),
  E('Aug14 Thu Revati  Di', DateTime(2025, 8,14), 27, 4,  187),
  E('Aug15 Fri Ashwni  Ra', DateTime(2025, 8,14),  1, 4, -546),
  E('Aug16 Sat Krttka  Di', DateTime(2025, 8,16),  3, 6,  167),
  E('Aug17 Sun Rohini  Ra', DateTime(2025, 8,16),  4, 6, -441),
  E('Aug18 Mon Mrgshr  Ra', DateTime(2025, 8,18),  5, 1,  -39),
  E('Aug19 Tue Ardra   Di', DateTime(2025, 8,19),  6, 2,  646),
  E('Aug20 Wed Pnrvsu  Ra', DateTime(2025, 8,20),  7, 3, -275),
  E('Aug21 Thu Pushya  Ra', DateTime(2025, 8,21),  8, 4,   -8),
  E('Aug22 Fri Ashlsh  Ra', DateTime(2025, 8,22),  9, 5, -285),
  E('Aug23 Sat Magha   Ra', DateTime(2025, 8,23), 10, 6, -259),
  E('Aug24 Sun PvPhg   Ra', DateTime(2025, 8,24), 11, 0,  -61),
  E('Aug25 Mon UtPhg   Ra', DateTime(2025, 8,25), 12, 1, -303),
  E('Aug26 Tue Hasta   Di', DateTime(2025, 8,26), 13, 2,  552),
  E('Aug27 Wed Chitra  Ra', DateTime(2025, 8,26), 14, 2, -370),
  E('Aug28 Thu Chitra  Ra', DateTime(2025, 8,28), 14, 4,  -13),
];

void main() {
  // Build map: (nk, vara) → list of (lbl, off, isDi)
  final Map<int, Map<int, List<(String, int)>>> table = {};
  for (int nk = 1; nk <= 27; nk++) table[nk] = {};
  for (int v = 0; v <= 6; v++) {
    for (int nk = 1; nk <= 27; nk++) table[nk]![v] = [];
  }

  for (final e in entries) {
    table[e.nk]![e.v]!.add((e.lbl, e.off));
  }

  print('═' * 90);
  print('27×7 Amrita Table — derived from ${entries.length} Sringeri reference entries');
  print('Encoding: +N = Di.Amrita N min from sunrise | -N = Ra.Amrita N min from sunset');
  print('═' * 90);
  print('');

  int cellsFilled = 0;
  int conflictCells = 0;

  for (int nk = 1; nk <= 27; nk++) {
    final row = table[nk]!;
    final List<String> cols = [];
    for (int v = 0; v <= 6; v++) {
      final vals = row[v]!;
      if (vals.isEmpty) {
        cols.add('  null ');
      } else if (vals.length == 1) {
        final off = vals[0].$2;
        final sign = off >= 0 ? '+' : '';
        cols.add(' $sign${off.toString().padLeft(4)} ');
        cellsFilled++;
      } else {
        // Multiple entries — check consistency
        final diVals = vals.where((x) => x.$2 >= 0).map((x) => x.$2).toList();
        final raVals = vals.where((x) => x.$2 < 0).map((x) => x.$2).toList();
        final List<String> parts = [];
        if (diVals.isNotEmpty) {
          final mean = diVals.reduce((a, b) => a + b) ~/ diVals.length;
          final spread = diVals.isEmpty ? 0 : diVals.reduce((a, b) => a > b ? a : b) - diVals.reduce((a, b) => a < b ? a : b);
          parts.add('Di:${mean}(±${spread})');
          cellsFilled++;
          if (spread > 30) conflictCells++;
        }
        if (raVals.isNotEmpty) {
          final mean = raVals.reduce((a, b) => a + b) ~/ raVals.length;
          final spread = raVals.isEmpty ? 0 : raVals.reduce((a, b) => a > b ? a : b) - raVals.reduce((a, b) => a < b ? a : b);
          parts.add('Ra:${mean}(±${spread})');
          cellsFilled++;
          if (spread > 30) conflictCells++;
        }
        cols.add(' [${parts.join('/')}] ');
      }
    }
    print('NK${nk.toString().padLeft(2)} ${nkNames[nk].padRight(17)}: ${cols.join('|')}');
  }

  print('');
  print('═' * 90);
  print('Cells filled: $cellsFilled / 189  (${(cellsFilled * 100 / 189).round()}%)');
  print('Conflict cells (spread > 30 min): $conflictCells');
  print('');
  print('Duplicate (nk, vara) pairs — consistency check:');
  print('─' * 90);
  for (int nk = 1; nk <= 27; nk++) {
    for (int v = 0; v <= 6; v++) {
      final vals = table[nk]![v]!;
      if (vals.length <= 1) continue;
      final diVals = vals.where((x) => x.$2 >= 0).toList();
      final raVals = vals.where((x) => x.$2 < 0).toList();
      if (diVals.length >= 2) {
        final offsets = diVals.map((x) => x.$2).toList();
        final spread = offsets.reduce((a, b) => a > b ? a : b) - offsets.reduce((a, b) => a < b ? a : b);
        final status = spread <= 30 ? '✓' : '✗ CONFLICT';
        print('NK$nk ${nkNames[nk].padRight(17)} ${varaNames[v]} Di: ${offsets.join(', ')} min  spread=$spread $status');
        for (final d in diVals) print('    ${d.$1}');
      }
      if (raVals.length >= 2) {
        final offsets = raVals.map((x) => x.$2).toList();
        final spread = offsets.reduce((a, b) => a > b ? a : b) - offsets.reduce((a, b) => a < b ? a : b);
        final status = spread <= 30 ? '✓' : '✗ CONFLICT';
        print('NK$nk ${nkNames[nk].padRight(17)} ${varaNames[v]} Ra: ${offsets.join(', ')} min  spread=$spread $status');
        for (final d in raVals) print('    ${d.$1}');
      }
    }
  }
}
