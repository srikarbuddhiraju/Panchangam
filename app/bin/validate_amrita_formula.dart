/// Validates the new Moon-fraction Amrita Kalam formula against all
/// verified Sringeri Panchangam entries.
///
/// For each entry: computes amritaStart using Muhurtha.amritKalam(),
/// compares against the Sringeri reference time, and prints the delta.
///
/// Run: dart run bin/validate_amrita_formula.dart
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/muhurtha.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/vara.dart';

const double lat = 12.9716; // Bengaluru
const double lng = 77.5946;

class E {
  final String lbl;
  final DateTime date;
  final int nk;
  final int v;
  final int off; // +Di min from sunrise, -Ra min from sunset
  E(this.lbl, this.date, this.nk, this.v, this.off);
}

final entries = [
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
  // ── February 2026 (full month — Sarvam OCR, Session 12) ─────────────────
  E('Jan29 Thu Mrgshr  Ra', DateTime(2026, 1,29),  5, 4, -113),
  E('Jan30 Fri Ardra   Di', DateTime(2026, 1,30),  6, 5,  634),
  E('Jan31 Sat Pnrvsu  Ra', DateTime(2026, 1,31),  7, 6, -301),
  E('Feb01 Sun Pushya  Ra', DateTime(2026, 2, 1),  8, 0,   -8),  // was -123 (27x7 table), corrected
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
  // Feb12 Thu Jyeshtha: NO AMRITA (అమృతఘటికాభావ) — skip
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
  // Feb27 Fri Ardra: NO AMRITA (అమృతఘటికాభావ) — skip
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
];

String fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

void main() {
  print('Amrita Formula Validation — New formula vs Sringeri reference');
  print('');
  print('${'Entry'.padRight(22)} Sringeri  Formula   ΔMin  Status');
  print('─' * 65);

  int pass = 0, fail = 0, miss = 0;
  final deltas = <int>[];

  for (final e in entries) {
    final times = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sunrise = times[0];
    final sunset  = times[1];
    final DateTime yesterday = e.date.subtract(const Duration(days: 1));
    final DateTime previousSunset = SunriseSunset.computeNOAA(yesterday, lat, lng)[1];

    // Sringeri reference time
    final DateTime sringeri = e.off >= 0
        ? sunrise.add(Duration(minutes: e.off))
        : sunset.add(Duration(minutes: -e.off));

    // Compute nakshatra at sunrise for the formula call
    final double jdSR = JulianDay.fromIST(sunrise);
    final int nkNum = Nakshatra.number(jdSR);
    final int vara  = Vara.fromDateTime(e.date);

    // New formula
    final List<DateTime>? result =
        Muhurtha.amritKalam(nkNum, vara, sunrise, sunset, previousSunset);

    if (result == null) {
      print('${e.lbl.padRight(22)} ${fmt(sringeri)}    --:--   ----  MISS (null)');
      miss++;
      continue;
    }

    final DateTime computed = result[0];
    final int delta = computed.difference(sringeri).inMinutes;
    deltas.add(delta.abs());

    final String status;
    if (delta.abs() <= 15) {
      status = 'OK';
      pass++;
    } else if (delta.abs() <= 30) {
      status = 'WARN(${delta > 0 ? '+' : ''}$delta)';
      fail++;
    } else {
      status = 'FAIL(${delta > 0 ? '+' : ''}$delta)';
      fail++;
    }

    print('${e.lbl.padRight(22)} ${fmt(sringeri)}    ${fmt(computed)}   '
        '${delta.toString().padLeft(4)}  $status');
  }

  print('─' * 65);
  deltas.sort();
  final int n = entries.length;
  final median = deltas.isNotEmpty ? deltas[deltas.length ~/ 2] : 0;
  final within15 = deltas.where((d) => d <= 15).length;
  final within30 = deltas.where((d) => d <= 30).length;
  print('');
  print('Results: $pass OK / ${fail + miss} not-OK (miss=$miss, warn/fail=$fail) out of $n');
  print('Within 15 min: $within15/$n  |  Within 30 min: $within30/$n  |  Median error: ${median}min');
}
