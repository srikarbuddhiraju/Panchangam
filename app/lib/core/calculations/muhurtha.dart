/// Muhurtha (auspicious/inauspicious window) calculations.
///
/// A Muhurtha is 1/30 of the day (sidereal day ÷ 30 = ~48 minutes).
/// For Panchangam purposes, we use daylight period ÷ 15 per half-day convention.
library;

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/data/amrita_lookup.dart';

class Muhurtha {
  Muhurtha._();

  /// Abhijit Muhurtha — the most auspicious window of the day.
  ///
  /// Centered on solar noon. Duration: 24 minutes before + 24 minutes after.
  /// NOT valid on Wednesdays (vara == 3).
  ///
  /// Returns [start, end] as IST DateTimes, or null for Wednesday.
  static List<DateTime>? abhijit(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    if (vara == 3) return null; // Wednesday — Abhijit not auspicious

    final int halfDaySeconds = sunset.difference(sunrise).inSeconds ~/ 2;
    final DateTime solarNoon = sunrise.add(Duration(seconds: halfDaySeconds));

    final DateTime start = solarNoon.subtract(const Duration(minutes: 24));
    final DateTime end = solarNoon.add(const Duration(minutes: 24));
    return [start, end];
  }

  /// Dur Muhurta — inauspicious period(s) each day.
  ///
  /// Each Dur Muhurta period = 1 muhurtha = dayDuration/15.
  /// Positions are weekday-specific (1-indexed muhurtha of the 15 daytime muhurthas).
  ///
  /// Returns list of [start, end] pairs.
  static List<List<DateTime>> durMuhurta(
    int vara,
    DateTime sunrise,
    DateTime sunset,
  ) {
    // Each muhurtha = daylight duration / 15
    final int daySeconds = sunset.difference(sunrise).inSeconds;
    final int muhurthaSeconds = daySeconds ~/ 15;

    // Weekday-specific Dur Muhurtha positions (1-indexed, one per day)
    // Based on traditional Panchangam tables
    const List<int> durPositions = [
      8,  // Sunday: 8th muhurtha
      7,  // Monday: 7th muhurtha
      7,  // Tuesday: 7th muhurtha
      2,  // Wednesday: 2nd muhurtha (special)
      10, // Thursday: 10th muhurtha
      7,  // Friday: 7th muhurtha
      9,  // Saturday: 9th muhurtha
    ];

    final int pos = durPositions[vara];
    // Convert 1-indexed position to seconds from sunrise
    final DateTime start =
        sunrise.add(Duration(seconds: (pos - 1) * muhurthaSeconds));
    final DateTime end = start.add(Duration(seconds: muhurthaSeconds));

    return [
      [start, end]
    ];
  }

  // ── Amrit Kalam ─────────────────────────────────────────────────────────────
  //
  // Formula (derived from Sringeri Panchangam 2025-26 data, Dec–Mar, 41 entries):
  //
  //   amritaStart = the moment Moon's sidereal longitude reaches a
  //                 nakshatra-specific TARGET LONGITUDE on the given date.
  //
  //   Target longitude for nakshatra N:
  //     targetLon(N) = (N-1) × 13.333° + _amritFrac[N-1] × 13.333°
  //
  //   Di.Amrita: amritaStart falls between sunrise and sunset.
  //   Ra.Amrita: amritaStart falls between sunset and next sunrise.
  //   Duration:  96 minutes (4 ghatikas), fixed.
  //
  // If Moon has already passed the target for the sunrise nakshatra, the
  // algorithm searches the NEXT nakshatra's target (handles the `!` entries
  // where Moon transitions mid-day).
  //
  // The 27×7 table (ARCHIVED below) was a single-year snapshot and is now
  // superseded by this formula. The weekday is NOT part of the formula.
  //
  // Derivation: for each nakshatra, fraction = (moonLon − nkStart) / nkSpan
  // at amritaStart was consistent across multiple months and different weekdays
  // (e.g. Anuradha: 57%/59%/59% across Thu/Wed/Tue; Vishaka: 65%/67% across
  // Wed/Tue). Di/Ra falls out naturally from whether targetTime < sunset.
  //
  // Ramakumar X values — hours offset from nakshatra start for a 24h nakshatra.
  // amritStart = nkEntryTime + (X/24) × nkDuration
  // Source: Karanam Ramakumar, Panchangam Calculations (archive.org)
  // docs/data/PanchangamCalculations_fulltext.txt
  static const List<double> _amritX = [
    16.8, //  1 Ashwini
    19.2, //  2 Bharani
    21.6, //  3 Krittika
    20.8, //  4 Rohini
    15.2, //  5 Mrigashirsha
    14.0, //  6 Ardra
    21.6, //  7 Punarvasu
    17.6, //  8 Pushyami
    22.4, //  9 Ashlesha
    21.6, // 10 Makha
    17.6, // 11 Pubba
    16.8, // 12 Uttara
    18.0, // 13 Hasta
    17.6, // 14 Chitra
    15.2, // 15 Swati
    15.2, // 16 Vishakha
    13.6, // 17 Anuradha
    15.2, // 18 Jyeshtha
    17.6, // 19 Moola
    19.2, // 20 Purvashadha
    17.6, // 21 Uttarashadha
    13.6, // 22 Shravana
    13.6, // 23 Dhanishtha
    16.8, // 24 Shatabhisha
    16.0, // 25 Purvabhadra
    19.2, // 26 Uttarabhadra
    21.6, // 27 Revati
  ];

  static const double _nkSpan = 360.0 / 27; // 13.333°

  /// Formula-only path — bypasses lookup table, used by validation scripts.
  static List<DateTime>? amritKalamFormulaOnly(
    DateTime sunrise, {
    double lng = 80.5,
  }) =>
      _amritKalamRamakumar(sunrise, lng: lng);

  /// Amrit Kalam — auspicious window published by Sringeri Panchangam.
  ///
  /// **Data source**: Sringeri Suvarnamukhya Panchangam (Surya Siddhanta edition),
  /// exact published times OCR'd and stored in [AmritaLookup].
  /// Times published for Kondavidu (80.5°E); deshantar correction applied per user lng.
  ///
  /// **Coverage**: Mar 2025 – Apr 2027 (updated annually when new Sringeri edition releases).
  ///
  /// **Outside coverage**: returns null. The formula fallback (Ramakumar) has a
  /// ~2-hour mean error vs Sringeri and is NOT shown to users. Use [amritKalamFormulaOnly]
  /// only in validation/diagnostic scripts.
  ///
  /// **Why no formula fallback?**
  /// Sringeri computes amrita kalam using proprietary software with internal calibration
  /// parameters that are not published. The best available formula (Karanam Ramakumar,
  /// *Panchangam Calculations*) has a mean error of ~130 min and is within 30 min
  /// only 23% of the time across 464 validated data points. Showing such results
  /// as authoritative would mislead users. We prefer honest null over misleading times.
  ///
  /// [previousSunset] — retained for API compatibility (unused).
  /// Returns [start, end] as IST DateTimes, or null if no data for this date.
  static List<DateTime>? amritKalam(
    int nakshatraNumber, // retained for API compatibility
    int vara,            // retained for API compatibility
    DateTime sunrise,
    DateTime sunset,
    DateTime previousSunset, {
    double lng = 80.5, // user longitude for deshantar correction; default = Kondavidu
  }) {
    // Sringeri lookup table — exact published times, covers Mar 2025 – Apr 2027.
    // Source: దేశాంతర సంస్కార నిర్ణయము, Sringeri Panchangam p.66.
    final DateTime dateOnly = DateTime(sunrise.year, sunrise.month, sunrise.day);
    if (!dateOnly.isBefore(AmritaLookup.rangeStart) &&
        !dateOnly.isAfter(AmritaLookup.rangeEnd)) {
      final (int, int)? entry = AmritaLookup.lookup(dateOnly);
      if (entry != null) {
        final (int h, int m) = entry;
        final int correctionMinutes = ((lng - 80.5) * 4).round();
        final DateTime amritStart =
            DateTime(sunrise.year, sunrise.month, sunrise.day, h, m)
                .add(Duration(minutes: correctionMinutes));
        return [amritStart, amritStart.add(const Duration(minutes: 96))];
      }
      // In range but entry is null: this is a confirmed no-amrita day.
      return null;
    }

    // Outside lookup coverage — no formula fallback. Return null.
    // See docstring above for why.
    return null;
  }

  /// Ramakumar formula: amritStart = nkEntryTime + (X/24) × nkDuration.
  ///
  /// 1. Find when Moon entered the current nakshatra (backward bisect from sunrise).
  /// 2. Find when Moon exits the current nakshatra (forward bisect from sunrise).
  /// 3. Apply X offset and compute duration proportionally (nkDuration / 15).
  static List<DateTime>? _amritKalamRamakumar(
    DateTime sunrise, {
    double lng = 80.5,
  }) {
    final double jdSunrise = JulianDay.fromIST(sunrise);
    final double moonLonAtSunrise = LunarPosition.siderealLongitude(jdSunrise);
    int nkIdx = (moonLonAtSunrise / _nkSpan).floor() % 27; // 0-based

    double nkStartLon = nkIdx * _nkSpan;
    // End of nakshatra 27 (Revati) wraps to 0° (start of Ashwini).
    double nkEndLon = ((nkIdx + 1) % 27) * _nkSpan;

    // Find nakshatra entry (Moon crossed nkStartLon before sunrise).
    DateTime nkEntry = _bisectLon(
      from: sunrise.subtract(const Duration(hours: 48)),
      to: sunrise,
      targetLon: nkStartLon,
    );

    // Find nakshatra exit (Moon crosses nkEndLon after sunrise).
    DateTime nkExit = _bisectLon(
      from: sunrise,
      to: sunrise.add(const Duration(hours: 48)),
      targetLon: nkEndLon,
    );

    // Ramakumar rule: if the sunrise NK ends within 1 hour of sunrise,
    // use the NEXT nakshatra instead (it predominates the day).
    // Source: Karanam Ramakumar, Panchangam Calculations, example p.17:
    // "as Rohini comes within one hour of sunrise, we should consider Rohini."
    if (nkExit.difference(sunrise).inMinutes < 60) {
      nkIdx = (nkIdx + 1) % 27;
      nkStartLon = nkEndLon; // previous NK's end = next NK's start
      nkEndLon = ((nkIdx + 1) % 27) * _nkSpan;
      nkEntry = nkExit; // next NK starts exactly when previous one ends
      nkExit = _bisectLon(
        from: nkEntry,
        to: nkEntry.add(const Duration(hours: 48)),
        targetLon: nkEndLon,
      );
    }

    final double nkDurationHrs =
        nkExit.difference(nkEntry).inMinutes / 60.0;

    // Sanity: nakshatra duration should be 15–30h.
    if (nkDurationHrs < 15.0 || nkDurationHrs > 30.0) return null;

    final double x = _amritX[nkIdx];
    final int offsetMin = ((x / 24.0) * nkDurationHrs * 60.0).round();
    final int durationMin = (nkDurationHrs * 60.0 / 15.0).round();
    final int correctionMin = ((lng - 80.5) * 4).round();

    final DateTime amritStart =
        nkEntry.add(Duration(minutes: offsetMin + correctionMin));

    // Validate: window must be within a reasonable range of this calendar day.
    // Pre-dawn Ra.Amrita can be several hours before sunrise; post-sunset can be
    // well into the following morning (26h+). Allow −10h to +28h from sunrise.
    final int minFromSunrise = amritStart.difference(sunrise).inMinutes;
    if (minFromSunrise < -10 * 60 || minFromSunrise > 28 * 60) return null;

    return [amritStart, amritStart.add(Duration(minutes: durationMin))];
  }

  /// Bisects to find when Moon's prograde sidereal longitude crosses [targetLon]
  /// within the time window [from, to].
  ///
  /// Uses prograde angular distance: dist = (targetLon − moonLon + 360) % 360.
  /// dist ∈ (0°, 180°) → Moon before target; else → Moon at/past target.
  /// This handles the 360°→0° wraparound (Revati→Ashwini) automatically.
  static DateTime _bisectLon({
    required DateTime from,
    required DateTime to,
    required double targetLon,
  }) {
    double lo = JulianDay.fromIST(from);
    double hi = JulianDay.fromIST(to);

    for (int i = 0; i < 50; i++) {
      final double mid = (lo + hi) / 2;
      final double lon = LunarPosition.siderealLongitude(mid);
      final double dist = (targetLon - lon + 360.0) % 360.0;
      if (dist > 0.0 && dist < 180.0) {
        lo = mid; // Moon still before target
      } else {
        hi = mid; // Moon at or past target
      }
    }

    return JulianDay.toIST((lo + hi) / 2);
  }

  // ── ARCHIVED: 27×7 lookup table (superseded by formula above) ───────────────
  //
  // Kept for cross-validation. This was a single-year snapshot (Feb 2026 full
  // month + spot entries). It was wrong in principle: the same nakshatra+weekday
  // gives different offsets in different years because the Moon's position within
  // the nakshatra at sunrise drifts continuously. Replaced Session 12.
  //
  // Source: Sringeri Panchangam Visvavasu 2025-26.
  // Encoding: null=unverified, 0=confirmed none, +N=Di min from sunrise,
  //           -N=Ra min from sunset.
  //
  // static const List<List<int?>> _amritTable = [
  //   //  Sun    Mon    Tue    Wed    Thu    Fri    Sat
  //   [   326,  null,  null,  null,  null,  null,  null], //  1 Ashwini    (Feb22)
  //   [  null,   382,  null,  null,  null,  null,  null], //  2 Bharani    (Feb23)
  //   [  null,  null,   434,  null,  null,  null,  null], //  3 Krittika   (Feb24)
  //   [  null,  null,  null,   274,  null,  null,  null], //  4 Rohini     (Feb25)
  //   [  null,  null,  null,  null,  -454,  null,  null], //  5 Mrigashirsha(Feb26)
  //   [  null,  null,     0,  null,  null,     0,  null], //  6 Ardra      (Jan27,Feb27)
  //   [  null,  null,  null,  null,  null,  null,    47], //  7 Punarvasu  (Feb28)
  //   [  -123,  null,  null,  null,  null,  null,  -144], //  8 Pushya     (Feb01,Mar28)
  //   [  null,  -258,  null,  null,  null,  null,  null], //  9 Ashlesha   (Feb02)
  //   [  null,  null,  -194,  null,  null,  null,  null], // 10 Magha      (Feb03)
  //   [  null,  null,  null,   626,  null,  null,  null], // 11 PvPhg      (Feb04)
  //   [  null,  null,  null,  null,   648,  null,  null], // 12 UtPhg      (Feb05)
  //   [  null,  null,  null,  null,  null,   -90,  null], // 13 Hasta      (Feb06)
  //   [  null,  null,  null,  null,  null,  null,  -153], // 14 Chitra     (Feb07)
  //   [  -116,  null,  null,  null,  null,  null,  null], // 15 Swati      (Feb08)
  //   [  null,  -254,  -289,  null,  null,  null,  null], // 16 Vishaka    (Feb09,Feb10)
  //   [  null,  null,  null,  -574,  null,  null,  null], // 17 Anuradha   (Feb11)
  //   [  null,  null,  null,  null,     0,  null,  null], // 18 Jyeshtha   (Feb12)
  //   [  null,  null,  null,  null,  null,   116,  null], // 19 Mula       (Feb13)
  //   [  null,  null,  null,  null,  null,  null,   354], // 20 PvAsh      (Feb14)
  //   [   362,  null,  null,  null,  null,  null,  null], // 21 UtAsh      (Feb15)
  //   [  null,   193,  null,  null,  null,  null,  null], // 22 Shravana   (Feb16)
  //   [  null,  null,   256,  null,  null,  null,  null], // 23 Dhanishtha (Feb17)
  //   [  null,  null,  null,   383,  null,  null,  null], // 24 Shatabhisha(Feb18)
  //   [  null,  null,  null,  null,   428,  null,  null], // 25 PvBhd      (Feb19)
  //   [  null,  null,  null,  null,  null,   586,  null], // 26 UtBhd      (Feb20)
  //   [  null,  null,  null,  null,  null,  null,   673], // 27 Revati     (Feb21)
  // ];
}
