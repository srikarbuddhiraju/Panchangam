// ============================================================================
// MISS FIX PROPOSAL — Backward search for pre-sunrise Ra Amrita
// ============================================================================
//
// FILE: proposed replacement for amritKalam() in
//       app/lib/core/calculations/muhurtha.dart
//
// PROBLEM RECAP
// -------------
// 7 validation entries return null (MISS). These are Ra amrita windows whose
// START TIME falls BEFORE sunrise — i.e. between yesterday's sunset and
// today's sunrise. The current forward-only search misses them because:
//
//   attempt=0: moonLon >= targetLon at jdSunrise → `continue`
//   attempt=1: searches from next nakshatra end, finds crossing ~18-26h later
//              (which is Di.Amrita of the NEXT day, not today's Ra.Amrita)
//
// The Moon crossed targetLon at, say, 01:07 AM — before sunrise. The code
// never looks backward for that crossing.
//
// WHY BACKWARD IS SAFE (no false positives)
// ------------------------------------------
// Each targetLon is crossed at most once per lunar cycle (~27.3 days).
// So "the most recent crossing before jdSunrise" is unambiguous and unique.
//
// The crossing is valid as TODAY's Ra amrita only if:
//   previousSunset < T_amrita < jdSunrise
//
// If T_amrita < previousSunset, the crossing belongs to the PREVIOUS day's
// Ra amrita context — skip it (return null for this day).
//
// What failed before: the bisection window was [jdSearch-1, jdSearch+1] which
// could straddle TWO crossings (one from the previous lunar cycle ~27 days
// earlier would NOT be in this window, but the window was anchored wrong and
// found the wrong monotonic segment). The correct fix: anchor the window
// tightly around jdSunrise — specifically [jdSunrise - 27h/24, jdSunrise].
// 27 hours is safely less than one lunar cycle (27.3 days × 24h = 655h), so
// only ONE crossing of targetLon can exist in any 27-hour window.
//
// JAN29 MRIGASHIRSHA RA (20:02) — SEPARATE ISSUE EXPLAINED AT BOTTOM
// ============================================================================

// ── Proposed amritKalam() replacement ───────────────────────────────────────
//
// Signature is unchanged — the call site in panchangam_engine.dart passes
// (nakshatraNum, varaNum, sunrise, sunset). We add `previousSunset` so the
// backward search can validate the Ra window. The call site must pass it.
//
// CALL SITE CHANGE (panchangam_engine.dart line ~82):
//
//   final List<DateTime>? amritTimes = Muhurtha.amritKalam(
//     nakshatraNum, varaNum, sunrise, sunset, previousSunset,
//   );
//
// previousSunset = SunriseSunset.compute(date.subtract(Duration(days: 1)), lat, lng)[1]
// (already computed cheaply — sunrise/sunset of yesterday)

static List<DateTime>? amritKalam(
  int nakshatraNumber, // retained for API compatibility, not used in formula
  int vara,            // retained for API compatibility, not used in formula
  DateTime sunrise,
  DateTime sunset,
  DateTime previousSunset, // NEW: yesterday's sunset, for backward-search validation
) {
  final double jdSunrise = JulianDay.fromIST(sunrise);
  final double jdPrevSunset = JulianDay.fromIST(previousSunset);

  // ── FORWARD SEARCH (existing logic, unchanged) ───────────────────────────
  // Try up to 2 nakshatras forward from sunrise.
  for (int attempt = 0; attempt < 2; attempt++) {
    final double jdSearch;
    if (attempt == 0) {
      jdSearch = jdSunrise;
    } else {
      final DateTime nkEnd = Nakshatra.endTime(jdSunrise);
      if (nkEnd.difference(sunrise).inMinutes > 24 * 60) return null;
      jdSearch = JulianDay.fromIST(nkEnd);
    }

    final double moonLon = LunarPosition.siderealLongitude(jdSearch);
    final int nkIdx = (moonLon / _nkSpan).floor() % 27;
    final double? frac = _amritFrac[nkIdx];
    if (frac == null) continue;

    final double targetLon = nkIdx * _nkSpan + frac * _nkSpan;

    if (moonLon >= targetLon) {
      // Moon already past target at this search point.
      // On attempt=0 (sunrise), this means T_amrita was BEFORE sunrise.
      // Attempt the backward search instead of continuing to attempt=1.
      if (attempt == 0) {
        final List<DateTime>? backwardResult = _searchBackward(
          targetLon: targetLon,
          jdSunrise: jdSunrise,
          jdPrevSunset: jdPrevSunset,
          sunrise: sunrise,
        );
        if (backwardResult != null) return backwardResult;
        // Backward search returned null (crossing was before yesterday's sunset
        // or Moon was never before targetLon in the search window). Fall through
        // to attempt=1 to look for a forward crossing in the next nakshatra.
      }
      continue; // attempt=1: also past target at nkEnd, keep trying
    }

    // Moon is before target — bisect forward (up to 48h).
    double lo = jdSearch;
    double hi = jdSearch + 2.0;
    for (int i = 0; i < 44; i++) {
      final double mid = (lo + hi) / 2;
      final double lon = LunarPosition.siderealLongitude(mid);
      final double dist = (targetLon - lon + 360) % 360;
      if (dist > 0 && dist < 180) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    final DateTime amritaStart = JulianDay.toIST((lo + hi) / 2);

    if (amritaStart.isBefore(sunrise)) continue;
    if (amritaStart.difference(sunrise).inMinutes > 26 * 60) return null;

    return [amritaStart, amritaStart.add(const Duration(minutes: 96))];
  }

  return null;
}

// ── Backward bisection helper ────────────────────────────────────────────────
//
// Finds the most recent time BEFORE jdSunrise when Moon was at targetLon.
// Search window: [jdSunrise - 27h, jdSunrise].
//
// 27h is chosen because:
//   - One nakshatra span = 13.333° out of 360°, Moon traverses it in ~27h
//   - The backward window must cover at most the time Moon takes to cross
//     one full nakshatra (the nakshatra the target falls in)
//   - 27h < lunar cycle (655h), so only one crossing of targetLon exists here
//
// Returns [T_amrita, T_amrita + 96min] if:
//   (a) a crossing was found (Moon goes from below→above targetLon in window)
//   (b) T_amrita > previousSunset (so it's Ra amrita of THIS day, not yesterday)
//
// Returns null otherwise.
static List<DateTime>? _searchBackward({
  required double targetLon,
  required double jdSunrise,
  required double jdPrevSunset,
  required DateTime sunrise,
}) {
  // Window: 27 hours before sunrise up to sunrise.
  final double lo = jdSunrise - 27.0 / 24.0;
  final double hi = jdSunrise;

  // Verify the window actually brackets the crossing:
  // Moon should be BEFORE targetLon at lo, and AT OR PAST targetLon at hi.
  final double lonAtLo = LunarPosition.siderealLongitude(lo);
  final double lonAtHi = LunarPosition.siderealLongitude(hi); // = moonLon at sunrise

  // dist = angular distance from lonAtLo to targetLon going eastward
  final double distAtLo = (targetLon - lonAtLo + 360) % 360;
  final double distAtHi = (targetLon - lonAtHi + 360) % 360;

  // For a valid crossing: Moon must be BEFORE target at lo (distAtLo in (0,180))
  // and AT or PAST target at hi (distAtHi == 0 or >= 180, i.e. not in (0,180)).
  // We already know distAtHi is NOT in (0,180) because the caller confirmed
  // moonLon >= targetLon at sunrise. But we must confirm the lo end.
  if (!(distAtLo > 0 && distAtLo < 180)) {
    // Moon was also past targetLon 27h ago — this nakshatra has no valid
    // backward crossing in our window (extremely rare; would mean Moon
    // crossed targetLon twice in 27h, which cannot happen).
    return null;
  }

  // Bisect within [lo, hi] to find the crossing.
  double searchLo = lo;
  double searchHi = hi;
  for (int i = 0; i < 44; i++) {
    final double mid = (searchLo + searchHi) / 2;
    final double lon = LunarPosition.siderealLongitude(mid);
    final double dist = (targetLon - lon + 360) % 360;
    if (dist > 0 && dist < 180) {
      searchLo = mid; // Moon still before target, push lo forward
    } else {
      searchHi = mid; // Moon at/past target, push hi backward
    }
  }

  final DateTime amritaStart = JulianDay.toIST((searchLo + searchHi) / 2);

  // Validate: T_amrita must be after yesterday's sunset.
  // If it's before yesterday's sunset, this crossing belongs to the day before.
  if (amritaStart.isBefore(previousSunset)) return null;

  // T_amrita must also be before sunrise (sanity check — should always hold
  // since hi=jdSunrise, but guard against floating point edge cases).
  if (!amritaStart.isBefore(sunrise)) return null;

  return [amritaStart, amritaStart.add(const Duration(minutes: 96))];
}

// ============================================================================
// WHY JAN29 MRIGASHIRSHA RA (20:02) IS A DIFFERENT ISSUE
// ============================================================================
//
// Jan29 Mrigashirsha Ra at Sringeri = 20:02 IST (after sunset, before midnight).
// This is firmly in the forward search zone — between sunset and +26h from sunrise.
// The forward search SHOULD find it. Yet it returns null (MISS).
//
// The most likely explanation: a nakshatra BOUNDARY issue at attempt=0/1.
//
// On Jan29, if the Moon is in Mrigashirsha at sunrise, _amritFrac[4] = 0.63.
// targetLon = 4 * 13.333 + 0.63 * 13.333 = 53.333 + 8.4 = 61.733°
//
// If moonLon at sunrise is already past 61.733° (e.g., Moon is at 62°), the
// forward search goes to attempt=1: it computes Nakshatra.endTime(jdSunrise)
// — the end of the Mrigashirsha nakshatra — then checks the nakshatra Moon is
// in at THAT point (which is Ardra, nkIdx=5). _amritFrac[5] = 0.54.
// targetLon for Ardra = 5 * 13.333 + 0.54 * 13.333 = 66.666 + 7.2 = 73.866°
//
// The forward bisect then finds when Moon reaches 73.866° — which might be
// 25-26h after sunrise. If it exceeds the 26h guard, it returns null.
// If it's within 26h, it returns the ARDRA window (not Mrigashirsha at 20:02).
//
// But wait — the backward search (new code above) at attempt=0 would also fire
// here: moonLon >= targetLon at sunrise → try backward. If T_amrita of the
// Mrigashirsha crossing was, say, 23:00 on Jan28 (before yesterday's sunset,
// which was ~18:00 Jan28), then backward returns null, and the code falls
// through to attempt=1 (Ardra). That Ardra window at ~26h would then also be
// rejected or returned wrongly.
//
// THE ACTUAL ROOT CAUSE FOR JAN29 needs diagnosis:
// -------------------------------------------------
// We need to know the actual Moon longitude at Jan29 sunrise.
// If Moon is in Ardra (lon > 66.666°) at sunrise on Jan29, then:
//   - nkIdx=5 (Ardra) at attempt=0
//   - targetLon = 73.866°
//   - If moonLon at sunrise < 73.866°, forward search finds it correctly!
//   - If moonLon >= 73.866°, backward search fires
//
// If Moon is at Mrigashirsha at sunrise (lon 53.333°–66.666°) but past 61.733°:
//   - attempt=0 backward: Mrigashirsha T_amrita was BEFORE sunrise (but when?)
//     If before yesterday's sunset → skipped. Jan28 sunset ~18:00.
//     If T_amrita was between Jan28 18:00 and Jan29 sunrise (~06:30) → valid!
//     But Sringeri says 20:02 on Jan29 — that's AFTER sunset, not before sunrise.
//     So T_amrita=20:02 should be found by forward search on attempt=0 or 1.
//
// CONCLUSION: Jan29 20:02 should be FORWARD-findable. It might be failing due
// to one of:
//   (a) The 26h guard: amritaStart.difference(sunrise).inMinutes > 26 * 60
//       If sunrise is ~06:30 and amrita is 20:02, diff = 13.5h → within 26h.
//       This is NOT the issue.
//   (b) moonLon >= targetLon at attempt=0 AND at nkEnd (attempt=1), causing
//       both to `continue` without the new backward search.
//   (c) A nakshatra boundary: Moon might be in the NEXT nakshatra at sunrise,
//       making attempt=0 search the wrong targetLon entirely. Then attempt=1
//       searches from nkEnd of THAT nakshatra, targeting a third nakshatra's
//       crossing — which is the day after.
//
// RECOMMENDATION: Add a diagnostic print for Jan29 to log:
//   - moonLon at sunrise
//   - nkIdx at attempt=0
//   - moonLon at Nakshatra.endTime(jdSunrise)
//   - nkIdx at attempt=1
//   - whether forward bisect finds a crossing and when
//
// Jan29 is likely a SEPARATE bug from the pre-sunrise cases and may need its
// own fix after the diagnostic. Do NOT conflate it with the backward search fix.
//
// ============================================================================
// CALL SITE UPDATE NEEDED (panchangam_engine.dart)
// ============================================================================
//
// Add previousSunset computation before the amritKalam call:
//
//   final DateTime yesterday = date.subtract(const Duration(days: 1));
//   final List<DateTime> yesterdaySunTimes =
//       SunriseSunset.compute(yesterday, lat, lng);
//   final DateTime previousSunset = yesterdaySunTimes[1];
//
//   final List<DateTime>? amritTimes = Muhurtha.amritKalam(
//     nakshatraNum, varaNum, sunrise, sunset, previousSunset,
//   );
//
// SunriseSunset.compute() is already imported and used on the same date.
// Adding one more call for yesterday is cheap (~1ms) and adds no dependencies.
// ============================================================================
