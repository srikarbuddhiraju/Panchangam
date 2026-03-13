/// Tests the "fixed duration from nakshatra entry" hypothesis.
///
/// For each Sringeri reference entry, computes:
///   1. Moon speed at the reference time (°/day)
///   2. Time of nakshatra entry (when Moon crossed current nkStart)
///   3. Duration from nakshatra entry to amrita = amrita_time - nk_entry_time (minutes)
///   4. Fraction of nakshatra at amrita time
///
/// If the formula is "amrita = nk_entry + X min", then 'duration from entry'
/// should be CONSISTENT across all months for the same nakshatra,
/// regardless of season/Moon speed.
///
/// Run: dart run bin/diagnose_nk_entry.dart
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/ayanamsa.dart';

const double lat  = 12.9716;
const double lng  = 77.5946;
const double nkSpan = 360.0 / 27;

const nkNames = [
  '', 'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'PurvaPhalguni',
  'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
  'Jyeshtha', 'Mula', 'PurvaAshadha', 'UttaraAshadha', 'Shravana',
  'Dhanishtha', 'Shatabhisha', 'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

class E {
  final String lbl;
  final int year;
  final int month;
  final int day;
  final int nk; // Sringeri's nakshatra label
  final int off;
  E(this.lbl, this.year, this.month, this.day, this.nk, this.off);
  DateTime get date => DateTime(year, month, day);
}

double moonSidLon(double jd) {
  final double t = LunarPosition.tropicalLongitude(jd);
  return JulianDay.normalize360(t - Ayanamsa.lahiri(jd));
}

/// Bisect to find when Moon crossed nkStart (the nakshatra boundary) within
/// the 48-hour window ending at [jdAmrita].
/// Returns JD of the crossing, or null if not found.
double? findNkEntry(int nkIdx, double jdAmrita) {
  final double nkStart = nkIdx * nkSpan;
  // Search up to 48h before amrita (one nakshatra takes 20–27h)
  double lo = jdAmrita - 2.0;
  double hi = jdAmrita;

  // Verify Moon is past nkStart at jdAmrita
  final double lonAtAmrita = moonSidLon(jdAmrita);
  final double distAtAmrita = (lonAtAmrita - nkStart + 360) % 360;
  if (distAtAmrita > 180) return null; // Moon already way past — shouldn't happen

  // Find a point where Moon was BEFORE nkStart
  double loLon = moonSidLon(lo);
  double distLo = (loLon - nkStart + 360) % 360;
  if (distLo < 180) {
    // Moon was already past nkStart 48h ago — go further back
    lo = jdAmrita - 3.0;
    loLon = moonSidLon(lo);
    distLo = (loLon - nkStart + 360) % 360;
    if (distLo < 180) return null; // Can't find entry in 72h window
  }

  // Bisect: find JD where Moon crosses nkStart
  for (int i = 0; i < 44; i++) {
    final double mid = (lo + hi) / 2;
    final double lon = moonSidLon(mid);
    final double dist = (lon - nkStart + 360) % 360;
    if (dist > 180) {
      lo = mid; // Moon still before nkStart → advance lo
    } else {
      hi = mid; // Moon at or past nkStart
    }
  }
  return (lo + hi) / 2;
}

/// Moon speed in degrees/day at a given JD (from finite difference).
double moonSpeed(double jd) {
  final double dt = 1.0 / 1440.0; // 1 minute
  final double lon1 = moonSidLon(jd - dt);
  final double lon2 = moonSidLon(jd + dt);
  double diff = (lon2 - lon1 + 360) % 360;
  if (diff > 180) diff -= 360;
  return diff / (2 * dt); // °/day
}

final entries = [
  // ── Same nakshatra across months ─────────────────────────────────────────
  // Ardra (NK6)
  E('Jan30 Ardra Di', 2026, 1, 30, 6, 634),
  E('Aug19 Ardra Di', 2025, 8, 19, 6, 646),
  // Vishakha (NK16)
  E('Dec17 Vishakha Di', 2025, 12, 17, 16,  71),
  E('Jan13 Vishakha Di', 2026,  1, 13, 16, 503),
  E('Apr15 Vishakha Di', 2025,  4, 15, 16, 523),
  E('Aug02 Vishakha Di', 2025,  8,  2, 16, 314),
  // Swati (NK15)
  E('Dec16 Swati Di',   2025, 12, 16, 15,  31),
  E('Jan12 Swati Di',   2026,  1, 12, 15, 358),
  E('Apr14 Swati Di',   2025,  4, 14, 15, 368),
  E('Aug01 Swati Di',   2025,  8,  1, 15, 677),
  // Punarvasu (NK7)
  E('Dec08 Punarvasu Di', 2025, 12,  8,  7,  30),
  E('Jan31 Punarvasu Ra', 2026,  1, 31,  7, -301),
  E('Feb28 Punarvasu Di', 2026,  2, 28,  7,  38),
  E('Apr06 Punarvasu Di', 2025,  4,  6,  7,  71),
  // Anuradha (NK17)
  E('Dec18 Anuradha Di', 2025, 12, 18, 17, 119),
  E('Jan14 Anuradha Di', 2026,  1, 14, 17, 546),
  E('Mar10 Anuradha Di', 2026,  3, 10, 17,  92),
  E('Feb11 Anuradha Ra', 2026,  2, 11, 17, -546),
  // Chitra (NK14)
  E('Jan11 Chitra Di',   2026,  1, 11, 14, 390),
  E('Apr13 Chitra Di',   2025,  4, 13, 14, 371),
  // Hasta (NK13)
  E('Jan10 Hasta Di',    2026,  1, 10, 13, 315),
  E('Apr12 Hasta Di',    2025,  4, 12, 13, 250),
  E('Aug26 Hasta Di',    2025,  8, 26, 13, 552),
  // Mrigashirsha (NK5)
  E('Jan02 Mrgshr Di',   2026,  1,  2,  5, 305),
  E('Dec06 Mrgshr Ra',   2025, 12,  6,  5, -446),
  E('Aug18 Mrgshr Ra',   2025,  8, 18,  5, -39),
];

void main() {
  print('Nakshatra Entry → Amrita duration test');
  print('Hypothesis: amrita = nkEntry + X min (fixed per nakshatra, not per fraction)');
  print('─' * 85);
  print('${'Label'.padRight(24)} NkIdx  MoonSpd  NkFrac  DurMin  NkEntry IST → Amrita IST');
  print('─' * 85);

  final Map<int, List<int>> durByNk = {};

  for (final e in entries) {
    final times = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sr = times[0], ss = times[1];
    final DateTime amritaTime = e.off >= 0
        ? sr.add(Duration(minutes: e.off))
        : ss.add(Duration(minutes: -e.off));

    final double jdAmrita = JulianDay.fromIST(amritaTime);
    final double lon = moonSidLon(jdAmrita);
    final int nkIdx = (lon / nkSpan).floor() % 27; // 0-based

    final double frac = (lon % nkSpan) / nkSpan;
    final double spd = moonSpeed(jdAmrita);

    // Find nakshatra entry
    final double? jdEntry = findNkEntry(nkIdx, jdAmrita);
    String entryStr = '--:--';
    int durMin = -1;
    if (jdEntry != null) {
      final DateTime entryTime = JulianDay.toIST(jdEntry);
      entryStr =
          '${entryTime.hour.toString().padLeft(2,'0')}:${entryTime.minute.toString().padLeft(2,'0')}';
      durMin = amritaTime.difference(entryTime).inMinutes;
      durByNk.putIfAbsent(nkIdx + 1, () => []).add(durMin);
    }

    final String amStr =
        '${amritaTime.hour.toString().padLeft(2,'0')}:${amritaTime.minute.toString().padLeft(2,'0')}';
    final String match = (nkIdx + 1 == e.nk) ? '✓' : '✗${e.nk}';

    print('${e.lbl.padRight(24)} NK${(nkIdx+1).toString().padLeft(2)} $match '
        '${spd.toStringAsFixed(2)} °/d  '
        '${frac.toStringAsFixed(3)}   '
        '${durMin.toString().padLeft(6)} min  '
        '$entryStr → $amStr');
  }

  print('');
  print('═' * 85);
  print('Duration from nakshatra entry, grouped by nakshatra:');
  print('─' * 85);
  final sortedEntries = durByNk.entries.toList()..sort((a, b) => a.key - b.key);
  for (final entry in sortedEntries) {
    final nk = entry.key;
    final durs = entry.value;
    if (durs.isEmpty) continue;
    final mean = durs.reduce((a, b) => a + b) / durs.length;
    final min = durs.reduce((a, b) => a < b ? a : b);
    final max = durs.reduce((a, b) => a > b ? a : b);
    print('NK$nk ${nkNames[nk].padRight(18)}: N=${durs.length}  '
        'mean=${mean.round()} min  spread=${max-min} min  '
        '[${min}–${max}]  '
        '≈ ${(mean/60).toStringAsFixed(1)}h');
  }
  print('');
  print('GATE: If spread < 60 min for most nakshatras → implement "nkEntry + duration" formula');
}
