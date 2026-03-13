/// Diagnostic: Can ayanamsha differences explain the Sringeri accuracy gap?
///
/// For each test case, at the Sringeri reference time we compute:
///   1. Tropical Moon longitude (from our Meeus Ch.47 formula)
///   2. Sidereal longitude under our Lahiri ayanamsha
///   3. Sidereal longitude under True Chitra Paksha (Lahiri + nutation term)
///   4. Which nakshatra/fraction each gives
///   5. What longitude shift would be needed to match Sringeri's timing exactly
///
/// Run: dart run bin/diagnose_ayanamsha.dart
import 'dart:math' as math;
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/ayanamsa.dart';

const double lat = 12.9716;
const double lng = 77.5946;
const double nkSpan = 360.0 / 27; // 13.3333°

// Representative test cases:
//   OK cases  (Dec/Jan): formula works fine
//   FAIL cases (Apr/Aug): formula gives large errors
//   Format: (label, date, nkSringeri, offMin, formulaDeltaMin)
//   offMin: +Di (min after SR), -Ra (min after SS of that date)
//   formulaDeltaMin: our formula's delta vs Sringeri (from validate output)
const cases = [
  // ── OK cases ─────────────────────────────────────────────────────────────
  ('Dec17 Vishakha Di  [OK,  Δ=0]',   2025, 12, 17, 16,  71,     0),
  ('Jan31 Punarvasu Ra [OK,  Δ=0]',   2026,  1, 31,  7,  -301,   0),
  ('Feb09 Vishakha Ra  [OK,  Δ=9]',   2026,  2,  9, 16, -238,    9),
  // ── FAIL cases ───────────────────────────────────────────────────────────
  ('Aug19 Ardra Di     [FAIL,-142]',  2025,  8, 19,  6,  646,  -142),
  ('Aug01 Swati Di     [FAIL,+133]',  2025,  8,  1, 15,  677,  133),
  ('Apr15 Vishakha Di  [FAIL,?]',     2025,  4, 15, 16,  523,    0), // unknown delta, calc below
  ('Apr13 Chitra Di    [FAIL,?]',     2025,  4, 13, 14,  371,    0),
];

/// True Chitra Paksha ayanamsha.
///
/// Adds the main nutation-in-longitude correction (Δψ) to Lahiri.
/// Δψ ≈ -17.2" × sin(Ω)  where Ω = Moon's ascending node.
/// This is the difference between "mean" (Lahiri) and "true" (nodal oscillation)
/// position of the vernal equinox relative to the ecliptic.
///
/// Note: The proper motion of Spica contributes ~0.04"/year (negligible for our purposes).
double trueCPAyanamsha(double jd) {
  final double T = JulianDay.julianCentury(jd);
  // Moon's ascending node (Ω) — Meeus Eq. 22.10
  double omega = 125.04452 - 1934.136261 * T + 0.0020708 * T * T;
  omega = omega % 360.0;
  if (omega < 0) omega += 360.0;
  // Nutation in longitude (main term only, arcseconds)
  final double deltaPsi = -17.2 * math.sin(omega * math.pi / 180.0);
  // Lahiri ayanamsha adds deltaPsi (True = Mean − Δψ in ecliptic convention)
  // Swiss Ephemeris SE_SIDM_TRUE_CITRA: ayanamsha = Lahiri + Δψ/3600
  return Ayanamsa.lahiri(jd) + deltaPsi / 3600.0;
}

String deg(double d) => '${d.toStringAsFixed(4)}°';

void main() {
  print('Ayanamsha Diagnostic — Can ayanamsha explain Sringeri errors?');
  print('Moon speed ≈ 0.5–0.65°/hr. 1° shift ≈ 90–120 min of amrita time.\n');

  for (final c in cases) {
    final (lbl, yr, mo, dy, nkS, offMin, formulaDelta) = c;
    final date = DateTime(yr, mo, dy);
    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sunrise = times[0];
    final sunset  = times[1];

    // Sringeri reference time
    final DateTime sringeri = offMin >= 0
        ? sunrise.add(Duration(minutes: offMin))
        : sunset.add(Duration(minutes: -offMin));

    final double jd = JulianDay.fromIST(sringeri);

    // 1. Tropical Moon longitude (same regardless of ayanamsha)
    final double tropLon = LunarPosition.tropicalLongitude(jd);

    // 2. Our Lahiri ayanamsha
    final double lahiriAy = Ayanamsa.lahiri(jd);
    final double sidLahiri = JulianDay.normalize360(tropLon - lahiriAy);
    final int nkLahiri = (sidLahiri / nkSpan).floor() + 1;
    final double fracLahiri = (sidLahiri % nkSpan) / nkSpan;

    // 3. True Chitra Paksha
    final double tcpAy = trueCPAyanamsha(jd);
    final double sidTCP = JulianDay.normalize360(tropLon - tcpAy);
    final int nkTCP = (sidTCP / nkSpan).floor() + 1;
    final double fracTCP = (sidTCP % nkSpan) / nkSpan;

    // 4. Difference between the two ayanamshas
    final double ayDiff = tcpAy - lahiriAy; // degrees

    // 5. What longitude shift is needed to match Sringeri's timing?
    //    If formulaDelta > 0: our formula is LATE, so our Moon is TOO FAR in NK
    //    If formulaDelta < 0: our formula is EARLY, so our Moon hasn't reached target yet
    //    Moon speed: approximate from the longitude change
    // Rough Moon speed: 13.2°/day ≈ 0.55°/hr ≈ 0.00917°/min
    final double moonSpeedDegPerMin = 13.2 / 1440.0;
    final double neededLonShift = formulaDelta * moonSpeedDegPerMin;

    print('── $lbl');
    print('   Sringeri time : ${sringeri.hour.toString().padLeft(2,'0')}:${sringeri.minute.toString().padLeft(2,'0')}  NK${nkS.toString().padLeft(2)}');
    print('   Tropical Moon : ${deg(tropLon)}');
    print('   Lahiri ay     : ${deg(lahiriAy)}  → sidereal ${deg(sidLahiri)}  NK$nkLahiri  frac=${fracLahiri.toStringAsFixed(3)}');
    print('   TCP ay        : ${deg(tcpAy)}  → sidereal ${deg(sidTCP)}    NK$nkTCP  frac=${fracTCP.toStringAsFixed(3)}');
    print('   Ay difference : ${(ayDiff * 60).toStringAsFixed(2)} arcmin  (${(ayDiff * 60 / moonSpeedDegPerMin / 60).toStringAsFixed(1)} min of amrita time)');
    if (formulaDelta != 0) {
      print('   Formula delta : ${formulaDelta > 0 ? '+' : ''}$formulaDelta min → needs ${deg(neededLonShift)} Moon shift');
      print('   Needed ay adj : ${deg(-neededLonShift)} to explain error via ayanamsha alone');
    }
    print('   NK match?     : Sringeri=NK$nkS  Lahiri=NK$nkLahiri  TCP=NK$nkTCP');
    print('');
  }

  print('══════════════════════════════════════════════════════════');
  print('Summary of ayanamsha difference (Lahiri vs True CP):');
  // Show the ayanamsha difference across a range of dates
  final testDates = [
    ('Dec 2025', DateTime(2025, 12, 15)),
    ('Jan 2026', DateTime(2026, 1, 15)),
    ('Apr 2025', DateTime(2025, 4, 15)),
    ('Aug 2025', DateTime(2025, 8, 15)),
  ];
  for (final (label, d) in testDates) {
    final jd = JulianDay.fromIST(d);
    final lahiri = Ayanamsa.lahiri(jd);
    final tcp = trueCPAyanamsha(jd);
    final diff = tcp - lahiri;
    final diffMin = diff * 60.0;
    final amritaDiff = (diff / (13.2 / 1440.0) / 60.0).toStringAsFixed(1);
    print('   $label : Lahiri=${deg(lahiri)}  TCP=${deg(tcp)}  Δ=${diffMin.toStringAsFixed(3)} arcmin  (~$amritaDiff min amrita)');
  }
}
