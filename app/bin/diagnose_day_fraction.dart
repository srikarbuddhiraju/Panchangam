/// Tests whether Di.Amrita fires at a fixed fraction of daylight
/// (muhurtha-based model) rather than at a Moon longitude target.
///
/// Hypothesis: amrita_start = sunrise + day_frac × (sunset - sunrise)
/// where day_frac is constant per nakshatra (possibly per weekday).
///
/// If confirmed → replace Moon fraction model for Di entries with daylight model.
///
/// Run: dart run bin/diagnose_day_fraction.dart
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';

const double lat = 12.9716; // Bengaluru
const double lng = 77.5946;
const double nkSpan = 360.0 / 27;

const List<String> nkNames = [
  '', 'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
  'PurvaPhalguni', 'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati',
  'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'PurvaAshadha',
  'UttaraAshadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
  'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

const List<String> dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class E {
  final String lbl;
  final DateTime date;
  final int nk;
  final int v;
  final int off; // +Di min from sunrise
  const E(this.lbl, this.date, this.nk, this.v, this.off);
}

// Di.Amrita entries only (off > 0)
final entries = [
  E('Dec01 Mon Revati  Di', DateTime(2025,12, 1), 27, 1,  660),
  E('Dec02 Tue Ashwini Di', DateTime(2025,12, 2),  1, 2,  305),
  E('Dec03 Wed Bharani Di', DateTime(2025,12, 3),  2, 3,  348),
  E('Dec04 Thu Krttika Di', DateTime(2025,12, 4),  3, 4,  383),
  E('Dec05 Fri Rohini  Di', DateTime(2025,12, 5),  4, 5,  238),
  E('Dec08 Mon Pnrvsu  Di', DateTime(2025,12, 8),  7, 1,   30),
  E('Dec10 Wed Ashlsh  Di', DateTime(2025,12,10),  9, 3,   73),
  E('Dec11 Thu Magha   Di', DateTime(2025,12,11), 10, 4,   37),
  E('Dec12 Fri PvPhg   Di', DateTime(2025,12,12), 11, 5,  -1), // skip Ra
  E('Dec17 Wed Vishka  Di', DateTime(2025,12,17), 16, 3,   71),
  E('Dec18 Thu Anrdha  Di', DateTime(2025,12,18), 17, 4,  119),
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
  E('Jan25 Sun Revati  Di', DateTime(2026, 1,25), 27, 0,  183),
  E('Jan30 Fri Ardra   Di', DateTime(2026, 1,30),  6, 5,  634),
  E('Feb04 Wed PvPhg   Di', DateTime(2026, 2, 4), 11, 3,  633),
  E('Feb05 Thu UtPhg   Di', DateTime(2026, 2, 5), 12, 4,  618),
  E('Feb13 Fri Mula    Di', DateTime(2026, 2,13), 19, 5,  106),
  E('Feb14 Sat PvAsh   Di', DateTime(2026, 2,14), 20, 6,  344),
  E('Feb15 Sun UtAsh   Di', DateTime(2026, 2,15), 21, 0,  352),
  E('Feb16 Mon Shrvan  Di', DateTime(2026, 2,16), 22, 1,  183),
  E('Feb17 Tue Dhnsth  Di', DateTime(2026, 2,17), 23, 2,  247),
  E('Feb18 Wed Shtbsh  Di', DateTime(2026, 2,18), 24, 3,  469),
  E('Feb19 Thu PvBhd   Di', DateTime(2026, 2,19), 25, 4,  428),
  E('Feb20 Fri UtBhd   Di', DateTime(2026, 2,20), 26, 5,  586),
  E('Feb21 Sat Revati  Di', DateTime(2026, 2,21), 27, 6,  673),
  E('Feb22 Sun Ashwni  Di', DateTime(2026, 2,22),  1, 0,  326),
  E('Feb23 Mon Bharni  Di', DateTime(2026, 2,23),  2, 1,  382),
  E('Feb24 Tue Krttka  Di', DateTime(2026, 2,24),  3, 2,  434),
  E('Feb25 Wed Rohini  Di', DateTime(2026, 2,25),  4, 3,  274),
  E('Feb28 Sat Pnrvsu  Di', DateTime(2026, 2,28),  7, 6,   47),
  E('Mar10 Tue Anrdha  Di', DateTime(2026, 3,10), 17, 2,   52),
  E('Mar11 Wed Jystha  Di', DateTime(2026, 3,11), 18, 3,  328),
  E('Mar12 Thu Mula    Di', DateTime(2026, 3,12), 19, 4,  469),
  E('Mar15 Sun Shrvan  Di', DateTime(2026, 3,15), 22, 0,  717),
];

void main() {
  print('Di.Amrita Day-Fraction Analysis');
  print('Hypothesis: amrita = sunrise + day_frac × (sunset − sunrise)');
  print('If day_frac consistent per nakshatra → muhurtha model confirmed');
  print('');

  // Collect per-nakshatra data
  final Map<int, List<_Row>> byNk = {};

  print('${'Entry'.padRight(22)} Sunrise  Sunset   Amrita   DayFrac  MoonFrac  MoonLon  NkAtAmrita');
  print('─' * 100);

  for (final e in entries) {
    if (e.off <= 0) continue; // skip Ra entries
    final times = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sunrise = times[0];
    final sunset  = times[1];
    final amrita  = sunrise.add(Duration(minutes: e.off));

    final int dayDurMin = sunset.difference(sunrise).inMinutes;
    final double dayFrac = e.off / dayDurMin;

    // Moon longitude at amrita time
    final double jdAmrita = JulianDay.fromIST(amrita);
    final double moonLon = LunarPosition.siderealLongitude(jdAmrita);
    final int nkAtAmrita = ((moonLon / nkSpan).floor() % 27) + 1;
    final double moonFracAtAmrita = (moonLon % nkSpan) / nkSpan;

    // Moon longitude at sunrise (to compute fraction at sunrise)
    final double jdSunrise = JulianDay.fromIST(sunrise);
    final double moonLonSunrise = LunarPosition.siderealLongitude(jdSunrise);
    final int nkAtSunrise = ((moonLonSunrise / nkSpan).floor() % 27) + 1;

    byNk.putIfAbsent(e.nk, () => <_Row>[]).add(_Row(
      lbl: e.lbl,
      dayFrac: dayFrac,
      moonFrac: moonFracAtAmrita,
      moonLon: moonLon,
      nkAtAmrita: nkAtAmrita,
      nkAtSunrise: nkAtSunrise,
      vara: e.v,
    ));

    print('${e.lbl.padRight(22)} ${_t(sunrise)}  ${_t(sunset)}   ${_t(amrita)}   '
        '${(dayFrac * 100).toStringAsFixed(1).padLeft(5)}%   '
        '${(moonFracAtAmrita * 100).toStringAsFixed(1).padLeft(5)}%  '
        '${moonLon.toStringAsFixed(2).padLeft(7)}°  '
        'NK${nkAtAmrita.toString().padLeft(2)} ${nkNames[nkAtAmrita]}');
  }

  print('');
  print('─── Per-Nakshatra Day-Fraction Summary ──────────────────────────────');
  print('');
  print('${'Nakshatra'.padRight(18)} Count  DayFrac vals             Mean    StdDev  CV%');
  print('─' * 80);

  final nkKeys = byNk.keys.toList()..sort();
  double totalDayFracCV = 0;
  double totalMoonFracCV = 0;
  int nkCount = 0;

  for (final nk in nkKeys) {
    final rows = byNk[nk]!;
    final fracs = rows.map((r) => r.dayFrac).toList();
    final mean = fracs.reduce((a, b) => a + b) / fracs.length;
    final variance = fracs.map((f) => (f - mean) * (f - mean)).reduce((a, b) => a + b) / fracs.length;
    final sd = variance == 0 ? 0.0 : variance < 0 ? 0.0 : _sqrt(variance);
    final cv = mean == 0 ? 0.0 : sd / mean * 100;

    final fracStr = fracs.map((f) => '${(f * 100).toStringAsFixed(1)}%').join(', ');

    print('${nkNames[nk].padRight(18)} ${rows.length.toString().padLeft(5)}  '
        '${fracStr.padRight(28)} ${(mean * 100).toStringAsFixed(1).padLeft(5)}%  '
        '${(sd * 100).toStringAsFixed(1).padLeft(5)}pp  ${cv.toStringAsFixed(0).padLeft(3)}%');

    if (rows.length >= 2) {
      totalDayFracCV += cv;
      nkCount++;
    }
  }

  print('');
  if (nkCount > 0) {
    print('Mean CV across nakshatras (dayFrac): ${(totalDayFracCV / nkCount).toStringAsFixed(1)}%');
  }

  print('');
  print('─── Muhurtha position analysis (dayFrac × 15) ───────────────────────');
  print('');
  print('A muhurtha = 1/15 of daylight. dayFrac × 15 = which muhurtha it fires in.');
  print('');
  print('${'Nakshatra'.padRight(18)} Count  Muhurtha position(s)');
  print('─' * 60);

  for (final nk in nkKeys) {
    final rows = byNk[nk]!;
    final muhurthas = rows.map((r) => (r.dayFrac * 15).toStringAsFixed(2)).join(', ');
    print('${nkNames[nk].padRight(18)} ${rows.length.toString().padLeft(5)}  $muhurthas');
  }

  print('');
  print('─── Comparison: day_frac CV vs moon_frac CV ─────────────────────────');
  print('');

  final Map<int, List<double>> moonFracByNk = {};
  for (final nk in nkKeys) {
    final rows = byNk[nk]!;
    moonFracByNk[nk] = rows.map((r) => r.moonFrac).toList();
  }

  print('${'Nakshatra'.padRight(18)} DayFrac CV%  MoonFrac CV%  Winner');
  print('─' * 60);

  int dayWins = 0, moonWins = 0;
  for (final nk in nkKeys) {
    final rows = byNk[nk]!;
    if (rows.length < 2) continue;

    final dayFracs = rows.map((r) => r.dayFrac).toList();
    final moonFracs = rows.map((r) => r.moonFrac).toList();

    final dayCv = _cv(dayFracs);
    final moonCv = _cv(moonFracs);
    final winner = dayCv < moonCv ? 'DAY ' : (moonCv < dayCv ? 'MOON' : 'TIE');
    if (dayCv < moonCv) dayWins++; else moonWins++;

    print('${nkNames[nk].padRight(18)} ${dayCv.toStringAsFixed(1).padLeft(8)}%  '
        '${moonCv.toStringAsFixed(1).padLeft(9)}%  $winner');
  }
  print('');
  print('Day-fraction wins: $dayWins / Moon-fraction wins: $moonWins out of ${dayWins + moonWins} nakshatras with ≥2 entries');
  print('');
  print('CONCLUSION:');
  if (dayWins > moonWins * 1.5) {
    print('  DAY-FRACTION MODEL IS BETTER → Di.Amrita fires at fixed muhurtha position');
    print('  Recommended action: replace _amritFrac with _amritDayFrac table');
  } else if (moonWins > dayWins * 1.5) {
    print('  MOON-FRACTION MODEL IS BETTER → current model is correct');
    print('  Errors likely from too few data points per nakshatra');
  } else {
    print('  INCONCLUSIVE — both models similar. Need more data per nakshatra.');
  }
}

class _Row {
  final String lbl;
  final double dayFrac;
  final double moonFrac;
  final double moonLon;
  final int nkAtAmrita;
  final int nkAtSunrise;
  final int vara;
  _Row({
    required this.lbl, required this.dayFrac, required this.moonFrac,
    required this.moonLon, required this.nkAtAmrita, required this.nkAtSunrise,
    required this.vara,
  });
}

double _cv(List<double> vals) {
  if (vals.length < 2) return 0;
  final mean = vals.reduce((a, b) => a + b) / vals.length;
  if (mean == 0) return 0;
  final variance = vals.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / vals.length;
  return variance <= 0 ? 0 : _sqrt(variance) / mean * 100;
}

double _sqrt(double x) {
  if (x <= 0) return 0;
  double r = x;
  for (int i = 0; i < 50; i++) r = (r + x / r) / 2;
  return r;
}

String _t(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
