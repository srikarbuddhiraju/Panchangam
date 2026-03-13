/// Compares Moon-longitude fraction vs fraction-of-daylight at Sringeri reference times.
/// Purpose: test whether Sringeri uses a fixed-ghati-from-sunrise formula
/// instead of Moon longitude fraction.
///
/// Run: dart run bin/diagnose_fraction.dart
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/ayanamsa.dart';

const double lat = 12.9716;
const double lng = 77.5946;
const double nkSpan = 360.0 / 27;

const nkNames = [
  '', 'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'PurvaPhalguni',
  'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
  'Jyeshtha', 'Mula', 'PurvaAshadha', 'UttaraAshadha', 'Shravana',
  'Dhanishtha', 'Shatabhisha', 'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

// Format: (label, yr, mo, dy, nkSringeri, offMin)
// offMin: +Di (min after SR), -Ra (min after SS of that date)
const cases = [
  // ── Ardra Di — same nakshatra, Jan vs Aug ────────────────────────────────
  ('Jan30 Ardra Di',    2026, 1, 30, 6,  634),
  ('Aug19 Ardra Di',    2025, 8, 19, 6,  646),
  // ── Vishakha Di — same nakshatra, Dec/Jan/Apr ────────────────────────────
  ('Dec17 Vishakha Di', 2025, 12, 17, 16, 71),
  ('Jan13 Vishakha Di', 2026,  1, 13, 16, 503),
  ('Apr15 Vishakha Di', 2025,  4, 15, 16, 523),
  // ── Swati Di — Jan vs Apr vs Aug ─────────────────────────────────────────
  ('Jan12 Swati Di',    2026, 1, 12, 15, 358),
  ('Apr14 Swati Di',    2025, 4, 14, 15, 368),
  ('Aug01 Swati Di',    2025, 8,  1, 15, 677),
  // ── Punarvasu — Di and Ra ────────────────────────────────────────────────
  ('Dec08 Punarvasu Di',2025, 12, 8, 7,  30),
  ('Feb28 Punarvasu Di',2026,  2, 28, 7,  38),
  ('Jan31 Punarvasu Ra',2026,  1, 31, 7, -301),
  // ── Chitra — Jan vs Aug ──────────────────────────────────────────────────
  ('Jan11 Chitra Di',   2026, 1, 11, 14, 390),
  ('Apr13 Chitra Di',   2025, 4, 13, 14, 371),
];

void main() {
  print('Fraction analysis: Moon fraction vs Day fraction at Sringeri reference time');
  print('If Sringeri uses fixed ghati, same NK should have same DayFrac across months.');
  print('If Sringeri uses Moon longitude, same NK should have same MoonFrac across months.\n');

  String p(double d) => d.toStringAsFixed(3);

  print('${'Label'.padRight(24)} Off    DayLen  DayFrac  MoonFrac  NK(ours)');
  print('─' * 75);

  for (final c in cases) {
    final (lbl, yr, mo, dy, _, offMin) = c;
    final date = DateTime(yr, mo, dy);
    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sr = times[0];
    final ss = times[1];

    final DateTime amritaTime = offMin >= 0
        ? sr.add(Duration(minutes: offMin))
        : ss.add(Duration(minutes: -offMin));

    final int dayLen = ss.difference(sr).inMinutes;
    final double dayFrac = offMin >= 0
        ? offMin / dayLen
        // For Ra: fraction of night elapsed
        : -offMin / (24 * 60 - dayLen);

    final double jd = JulianDay.fromIST(amritaTime);
    final double tropLon = LunarPosition.tropicalLongitude(jd);
    final double ay = Ayanamsa.lahiri(jd);
    double sidLon = tropLon - ay;
    sidLon = sidLon % 360.0;
    if (sidLon < 0) sidLon += 360.0;

    final int nkOurs = (sidLon / nkSpan).floor() + 1;
    final double moonFrac = (sidLon % nkSpan) / nkSpan;

    print('${lbl.padRight(24)} ${offMin.toString().padLeft(6)}  ${dayLen.toString().padLeft(6)}  ${p(dayFrac)}    ${p(moonFrac)}  NK$nkOurs ${nkNames[nkOurs]}');
  }

  print('');
  print('Key: DayFrac = offset / dayLength (Di) or offset / nightLength (Ra)');
  print('     MoonFrac = Moon longitude fraction within computed nakshatra');
}
