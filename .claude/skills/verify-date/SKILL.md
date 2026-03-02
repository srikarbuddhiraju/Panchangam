---
name: verify-date
description: Verify all five Panchangam elements for a given date (YYYY-MM-DD)
---

Verify Panchangam calculations for: `$ARGUMENTS`

**Steps:**
1. Run from project root: `dart run bin/validate.dart`
   (This runs Hyderabad calculations — lat 17.385°N, lon 78.487°E, tz Asia/Kolkata)
2. Find the output row(s) for `$ARGUMENTS`
3. Report all five Panchangam elements: Tithi, Nakshatra, Yoga, Karana, Vaara
4. Compare against any reference values Srikar provides
5. Flag any anomalies

**Source priority (CLAUDE.md rule):**
1. Sringeri Panchangam (primary standard — Sringeri Matha)
2. TTD Panchangam
3. DrikPanchang (last resort)

**Known-good anchors to cross-check against:**
- Samvatsara anchor: Visvavasu = Shaka 1947 (index 38)
- Yamaganda Saturday multiplier = 5 (position P6), table: [4,3,2,1,0,7,5]
- Karana formula: `(seq-2)%7`; seq 1 = Kimstughna (fixed)
- Telugu months: Amavasyant (find next Amavasya → read sun rashi)
- Adhika Maasa naming: uses FOLLOWING Nija month's rashi (nextNextAm)
- Solar position: VSOP87 (Meeus Ch.27), ~0.001° accuracy

If `$ARGUMENTS` is empty, default to today: `2026-03-02`
