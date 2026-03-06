/// Amrita pattern analysis — find the formula.
///
/// For each verified Sringeri entry, compute:
///   - Moon's sidereal longitude at amritaStart
///   - Fraction through the nakshatra (0.0 = start, 1.0 = end)
///   - nakshatraEnd − amritaStart (minutes)
///
/// If fraction is consistent → amrita starts when Moon is X% through nakshatra.
/// If (nkEnd − amritaStart) is consistent → amrita = last N minutes of nakshatra.
///
/// Run: dart run bin/amrita_pattern.dart
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 17.3850;
const double lng = 78.4867;
const double nkSpan = 360.0 / 27; // 13.333°

class E {
  final String lbl;
  final DateTime date;
  final int nk; // nakshatra at sunrise (Sringeri label)
  final int v;  // vara 0–6
  final int off; // +Di = min from sunrise, negative Ra = min from sunset
  E(this.lbl, this.date, this.nk, this.v, this.off);
}

final entries = [
  // ── December 2025 (sringeri_dec2025_parsed.md) ───────────────────────────
  E('Dec01 Mon Revati  Di',  DateTime(2025,12, 1), 27, 1,  660),
  E('Dec02 Tue Ashwini Di',  DateTime(2025,12, 2),  1, 2,  305),
  E('Dec03 Wed Bharani Di',  DateTime(2025,12, 3),  2, 3,  348),
  E('Dec04 Thu Krttika Di',  DateTime(2025,12, 4),  3, 4,  383),
  E('Dec05 Fri Rohini  Di',  DateTime(2025,12, 5),  4, 5,  238),
  E('Dec06 Sat Mrgshr  Ra',  DateTime(2025,12, 6),  5, 6, -446),
  E('Dec08 Mon Pnrvsu  Di',  DateTime(2025,12, 8),  7, 1,   30),
  E('Dec10 Wed Ashlsh  Di',  DateTime(2025,12,10),  9, 3,   73),
  E('Dec11 Thu Magha   Di',  DateTime(2025,12,11), 10, 4,   37),
  E('Dec12 Fri PvPhg   Ra',  DateTime(2025,12,12), 11, 5, -495),
  E('Dec13 Sat UtPhg   Ra',  DateTime(2025,12,13), 12, 6, -649),
  E('Dec14 Sun Hasta   Ra',  DateTime(2025,12,14), 13, 0, -722),
  E('Dec15 Mon Chitra  Di',  DateTime(2025,12,15), 14, 1,   57),
  E('Dec16 Tue Swati   Di',  DateTime(2025,12,16), 15, 2,   31),
  E('Dec17 Wed Vishka  Di',  DateTime(2025,12,17), 16, 3,   71),
  E('Dec18 Thu Anrdha  Di',  DateTime(2025,12,18), 17, 4,  119),
  // ── January 2026 (sringeri_jan2026.txt, IST clock times) ─────────────────
  E('Jan02 Fri Mrgshr  Di',  DateTime(2026, 1, 2),  5, 5,  305),
  E('Jan05 Mon Pushya  Di',  DateTime(2026, 1, 5),  8, 1,  216),
  E('Jan07 Wed Magha   Di',  DateTime(2026, 1, 7), 10, 3,  401),
  E('Jan08 Thu PvPhg   Di',  DateTime(2026, 1, 8), 11, 4,  175),
  E('Jan09 Fri UtPhg   Di',  DateTime(2026, 1, 9), 12, 5,  169),
  E('Jan10 Sat Hasta   Di',  DateTime(2026, 1,10), 13, 6,  315),
  E('Jan11 Sun Chitra  Di',  DateTime(2026, 1,11), 14, 0,  390),
  E('Jan12 Mon Swati   Di',  DateTime(2026, 1,12), 15, 1,  358),
  E('Jan13 Tue Vishka  Di',  DateTime(2026, 1,13), 16, 2,  503),
  E('Jan14 Wed Anrdha  Di',  DateTime(2026, 1,14), 17, 3,  546),
  E('Jan15 Thu Jystha  Ra',  DateTime(2026, 1,15), 18, 4, -130),
  E('Jan20 Tue Shrvan  Ra',  DateTime(2026, 1,20), 22, 2, -545),
  E('Jan25 Sun Revati  Di',  DateTime(2026, 1,25), 27, 0,  183),
  E('Jan26 Mon Ashwni  Ra',  DateTime(2026, 1,26),  1, 1, -636),
  // ── February 2026 (full month — Sarvam OCR Session 12) ─────────────────────
  E('Jan29 Thu Mrgshr  Ra',  DateTime(2026, 1,29),  5, 4, -113),
  E('Jan30 Fri Ardra   Di',  DateTime(2026, 1,30),  6, 5,  634),
  E('Jan31 Sat Pnrvsu  Ra',  DateTime(2026, 1,31),  7, 6, -301),
  E('Feb01 Sun Pushya  Ra',  DateTime(2026, 2, 1),  8, 0,   -8),
  E('Feb02 Mon Ashlsh  Ra',  DateTime(2026, 2, 2),  9, 1, -244),
  E('Feb03 Tue Magha   Ra',  DateTime(2026, 2, 3), 10, 2, -179),
  E('Feb04 Wed PvPhg   Di',  DateTime(2026, 2, 4), 11, 3,  633),
  E('Feb05 Thu UtPhg   Di',  DateTime(2026, 2, 5), 12, 4,  618),
  E('Feb06 Fri Hasta   Ra',  DateTime(2026, 2, 6), 13, 5,  -71),
  E('Feb07 Sat Chitra  Ra',  DateTime(2026, 2, 7), 14, 6, -138),
  E('Feb08 Sun Swati   Ra',  DateTime(2026, 2, 8), 15, 0, -101),
  E('Feb09 Mon Vishka  Ra',  DateTime(2026, 2, 9), 16, 1, -238),
  E('Feb10 Tue Vishka  Ra',  DateTime(2026, 2,10), 16, 2, -285),
  E('Feb11 Wed Anrdha  Ra',  DateTime(2026, 2,11), 17, 3, -546),
  E('Feb13 Fri Mula    Di',  DateTime(2026, 2,13), 19, 5,  106),
  E('Feb14 Sat PvAsh   Di',  DateTime(2026, 2,14), 20, 6,  344),
  E('Feb15 Sun UtAsh   Di',  DateTime(2026, 2,15), 21, 0,  352),
  E('Feb16 Mon Shrvan  Di',  DateTime(2026, 2,16), 22, 1,  183),
  E('Feb17 Tue Dhnsth  Di',  DateTime(2026, 2,17), 23, 2,  247),
  E('Feb18 Wed Shtbsh  Di',  DateTime(2026, 2,18), 24, 3,  469),
  E('Feb19 Thu PvBhd   Di',  DateTime(2026, 2,19), 25, 4,  418),
  E('Feb20 Fri UtBhd   Di',  DateTime(2026, 2,20), 26, 5,  579),
  E('Feb21 Sat Revati  Di',  DateTime(2026, 2,21), 27, 6,  663),
  E('Feb22 Sun Ashwni  Di',  DateTime(2026, 2,22),  1, 0,  317),
  E('Feb23 Mon Bharni  Di',  DateTime(2026, 2,23),  2, 1,  368),
  E('Feb24 Tue Krttka  Di',  DateTime(2026, 2,24),  3, 2,  409),
  E('Feb25 Wed Rohini  Di',  DateTime(2026, 2,25),  4, 3,  265),
  E('Feb26 Thu Mrgshr  Ra',  DateTime(2026, 2,26),  5, 4, -426),
  E('Feb28 Sat Pnrvsu  Di',  DateTime(2026, 2,28),  7, 6,   38),
  // ── March 2026 (sringeri_mar2026_parsed.md) ───────────────────────────────
  E('Mar10 Tue Anrdha  Di',  DateTime(2026, 3,10), 17, 2,   92),
  E('Mar11 Wed Jystha  Di',  DateTime(2026, 3,11), 18, 3,  248),
  E('Mar12 Thu Mula    Di',  DateTime(2026, 3,12), 19, 4,  560),
  E('Mar13 Fri PvAsh   Ra',  DateTime(2026, 3,13), 20, 5,  -95),
  E('Mar14 Sat UtAsh   Ra',  DateTime(2026, 3,14), 21, 6, -104),
  E('Mar15 Sun Shrvan  Di',  DateTime(2026, 3,15), 22, 0,  656),
  E('Mar16 Mon Dhnsth  Ra',  DateTime(2026, 3,16), 23, 1,   -8),
  E('Mar17 Tue Shtbsh  Ra',  DateTime(2026, 3,17), 24, 2, -218),
  E('Mar18 Wed PvBhd   Ra',  DateTime(2026, 3,18), 25, 3, -194),
  E('Mar19 Thu UtBhd   Ra',  DateTime(2026, 3,19), 26, 4, -358),
];

String fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

void main() {
  print('Amrita Pattern Analysis — Moon fraction at amritaStart');
  print('');
  print('${'Entry'.padRight(22)} amrita  nkTrans  Δtrans  moonLon  nkStart  frac%  nkEnd  Δend');
  print('─' * 96);

  final fracs = <double>[];
  final deltas = <int>[];
  final transDeltas = <int>[];

  for (final e in entries) {
    final times = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sunrise = times[0];
    final sunset  = times[1];

    final DateTime amritaStart = e.off >= 0
        ? sunrise.add(Duration(minutes: e.off))
        : sunset.add(Duration(minutes: -e.off));

    final double jdAmrita = JulianDay.fromIST(amritaStart);
    final double moonLon  = LunarPosition.siderealLongitude(jdAmrita);

    // Nakshatra at amritaStart (may differ from sunrise nakshatra for late Ra entries)
    final int nkAtAmrita  = Nakshatra.number(jdAmrita);
    final double nkStart  = (nkAtAmrita - 1) * nkSpan;
    final double frac     = (moonLon - nkStart) / nkSpan; // 0.0–1.0

    // nakshatraEnd computed from amritaStart JD (not sunrise JD)
    final DateTime nkEnd  = Nakshatra.endTime(jdAmrita);
    final int deltaMin    = nkEnd.difference(amritaStart).inMinutes;

    fracs.add(frac);
    deltas.add(deltaMin);

    // Flag if moonLon nakshatra ≠ sunrise nakshatra
    final jdSR = JulianDay.fromIST(sunrise);
    final nkAtSR = Nakshatra.number(jdSR);
    final diffFlag = nkAtAmrita != nkAtSR ? '!' : ' ';

    // Transition moment: when does the SUNRISE nakshatra end?
    final DateTime nkTrans   = Nakshatra.endTime(jdSR);
    final int transDelta     = amritaStart.difference(nkTrans).inMinutes;
    transDeltas.add(transDelta);

    print('${e.lbl.padRight(22)} ${fmt(amritaStart)}  '
        '${fmt(nkTrans)}  ${transDelta.toString().padLeft(6)}  '
        '${moonLon.toStringAsFixed(1).padLeft(6)}°  '
        '${nkStart.toStringAsFixed(1).padLeft(6)}°  '
        '${(frac * 100).toStringAsFixed(0).padLeft(3)}%$diffFlag  '
        '${fmt(nkEnd)}  ${deltaMin.toString().padLeft(5)}');
  }

  print('─' * 96);
  fracs.sort();
  deltas.sort();
  transDeltas.sort();
  final fracMin = (fracs.first * 100).toStringAsFixed(0);
  final fracMax = (fracs.last  * 100).toStringAsFixed(0);
  final fracMed = (fracs[fracs.length ~/ 2] * 100).toStringAsFixed(0);
  final near96  = deltas.where((d) => d >= 80 && d <= 112).length;
  final nearZero = transDeltas.where((d) => d.abs() <= 30).length;
  final near96t  = transDeltas.where((d) => d >= 80 && d <= 112).length;
  print('');
  print('Moon fraction range: $fracMin% … $fracMax%  |  median: $fracMed%');
  print('nkEnd−amrita within 80–112 min: $near96/${deltas.length}');
  print('');
  print('Transition delta (amritaStart − nkTransition):');
  print('  Min: ${transDeltas.first}  Max: ${transDeltas.last}  Median: ${transDeltas[transDeltas.length ~/ 2]}');
  print('  Within ±30 min of transition: $nearZero/${transDeltas.length}');
  print('  Within 80–112 min after transition: $near96t/${transDeltas.length}');
}
