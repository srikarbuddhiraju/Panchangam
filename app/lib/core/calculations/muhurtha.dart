/// Muhurtha (auspicious/inauspicious window) calculations.
///
/// A Muhurtha is 1/30 of the day (sidereal day ÷ 30 = ~48 minutes).
/// For Panchangam purposes, we use daylight period ÷ 15 per half-day convention.
library;

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';

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
  // Confidence: 39/41 verified Sringeri entries validated within ~15 min.
  // Outliers: Dec08 Punarvasu (nakshatra boundary issue) and Jan07 Magha
  // (amrita fires at nakshatra transition moment, not at target fraction).

  // Target fraction F for each nakshatra (0.0–1.0).
  // amritaStart = time when Moon reaches nkStart + F × 13.333°.
  // null = no direct data; algorithm falls through to next nakshatra's target.
  //
  // Sources: Dec 2025 (17 entries), Jan 2026 (14 entries), Mar 2026 (10 entries).
  static const List<double?> _amritFrac = [
    0.57, //  1 Ashwini          (Dec02 Tue 57%)
    0.73, //  2 Bharani          (Dec03 Wed 73%)
    0.90, //  3 Krittika         (Dec04 Thu 90%)
    0.94, //  4 Rohini           (Dec05 Fri 94%)
    0.61, //  5 Mrigashirsha     (Jan02 Fri 61%)
    0.76, //  6 Ardra            (Dec06 Sat! 76% — "0" on other dates means window missed)
    0.13, //  7 Punarvasu        (Dec08 Mon 13% — uncertain, near nk boundary)
    0.84, //  8 Pushya           (Jan05 86%, Feb01 83% → avg 84%)
    0.23, //  9 Ashlesha         (Dec10 Wed 23%)
    0.18, // 10 Magha            (Dec11 Thu 18%; Jan07 is outlier)
    0.87, // 11 Purva Phalguni   (Dec12 85%, Jan08 89% → avg 87%)
    0.85, // 12 Uttara Phalguni  (Dec13 86%, Jan09 84% → avg 85%)
    0.86, // 13 Hasta            (Jan10 86%; Dec14 has !)
    0.85, // 14 Chitra           (Dec15 87%, Jan11 82% → avg 85%)
    0.72, // 15 Swati            (Dec16 74%, Jan12 69% → avg 72%)
    0.66, // 16 Vishaka          (Dec17 65%, Jan13 67% → avg 66%)
    0.58, // 17 Anuradha         (Dec18 57%, Jan14 59%, Mar10 59% → avg 58%)
    0.61, // 18 Jyeshtha         (Jan15 64%, Mar11 57% → avg 61%)
    0.66, // 19 Mula             (Mar12 Thu 66%)
    0.73, // 20 Purva Ashadha    (Mar13 Fri 73%)
    0.66, // 21 Uttara Ashadha   (Mar14 Sat 66%)
    0.49, // 22 Shravana         (Mar15 Sun 49%; Jan20 has !)
    0.51, // 23 Dhanishtha       (Mar16 Mon 51%)
    null, // 24 Shatabhisha      (no direct data; falls through to PvBhd via !)
    0.67, // 25 Purva Bhadrapada (Mar18 67%; Mar17 ! → 66% in PvBhd → avg 67%)
    0.84, // 26 Uttara Bhadrapada(Mar19 Thu 84%)
    0.79, // 27 Revati           (Dec01 73%, Jan25 84% → avg 79%)
  ];

  static const double _nkSpan = 360.0 / 27; // 13.333°

  /// Amrit Kalam — auspicious 96-minute window, formula-based.
  ///
  /// Finds the time when Moon's sidereal longitude reaches the target
  /// nakshatra-specific fraction, using bisection over LunarPosition.
  ///
  /// Returns [start, end] as IST DateTimes, or null when window is outside
  /// the 24h period starting at sunrise (missed before sunrise or too far out).
  static List<DateTime>? amritKalam(
    int nakshatraNumber, // retained for API compatibility, not used in formula
    int vara,            // retained for API compatibility, not used in formula
    DateTime sunrise,
    DateTime sunset,
  ) {
    final double jdSunrise = JulianDay.fromIST(sunrise);

    // Try up to 2 nakshatras: sunrise nakshatra, then the one after transition.
    for (int attempt = 0; attempt < 2; attempt++) {
      final double jdSearch;
      if (attempt == 0) {
        jdSearch = jdSunrise;
      } else {
        // Search from after the sunrise nakshatra's end (transition point).
        final DateTime nkEnd = Nakshatra.endTime(jdSunrise);
        // Don't search beyond 24h from sunrise.
        if (nkEnd.difference(sunrise).inMinutes > 24 * 60) return null;
        jdSearch = JulianDay.fromIST(nkEnd);
      }

      final double moonLon = LunarPosition.siderealLongitude(jdSearch);
      final int nkIdx = (moonLon / _nkSpan).floor() % 27; // 0-based index
      final double? frac = _amritFrac[nkIdx];
      if (frac == null) continue; // no target for this nakshatra, try next

      final double targetLon = nkIdx * _nkSpan + frac * _nkSpan;
      if (moonLon >= targetLon) continue; // Moon already past target, try next

      // Bisect to find when Moon reaches targetLon (search up to 48h forward).
      // Uses angular prograde distance to handle Revati→Ashwini 360°→0° wraparound.
      double lo = jdSearch;
      double hi = jdSearch + 2.0;
      for (int i = 0; i < 44; i++) {
        final double mid = (lo + hi) / 2;
        final double lon = LunarPosition.siderealLongitude(mid);
        // Angular distance from lon to targetLon in prograde (eastward) direction.
        // If < 180°, Moon hasn't yet reached target → advance lo.
        final double dist = (targetLon - lon + 360) % 360;
        if (dist > 0 && dist < 180) {
          lo = mid; // Moon still before target
        } else {
          hi = mid; // Moon at or past target
        }
      }

      final DateTime amritaStart = JulianDay.toIST((lo + hi) / 2);

      // Must start after sunrise and within 26h of sunrise.
      // Ra.Amrita can fall in early morning of the next day (up to ~23h from sunrise).
      if (amritaStart.isBefore(sunrise)) continue;
      if (amritaStart.difference(sunrise).inMinutes > 26 * 60) return null;

      return [amritaStart, amritaStart.add(const Duration(minutes: 96))];
    }

    return null;
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
