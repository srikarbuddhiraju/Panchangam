# Latest Task — Session 16 In Progress

**Last updated:** Mar 7, 2026
**Branch:** `feature/ayanamsha-calibration`

---

## Session 16 Summary (In Progress)

**Goal**: Improve amrita kalam accuracy from 22% to ≤5 min.

**What was done this session**:
1. Implemented `_searchBackward()` in `muhurtha.dart` — backward bisection for pre-sunrise Ra.Amrita
2. Added `previousSunset` parameter to `amritKalam()` — passes yesterday's sunset as validation gate
3. Updated call sites: `panchangam_engine.dart`, `validate_amrita_formula.dart`, `validate_amrit.dart`
4. Added 45-minute guard: backward result only used if crossing is within 45 min of sunrise
5. Built + installed release APK (58.8 MB) on device 10BDAH07CM000MQ

**Validation results (after changes)**:
- 15 OK / 54 not-OK (miss=6, was miss=7)
- Within 15 min: 15/69 (unchanged)
- Within 30 min: 23/69 (was 22)
- Median error: 37 min (unchanged)
- Jan20 Shravana Ra: MISS → FAIL(-33) — improvement (02:36 vs Sringeri 03:09)

**Device verification**: APK installed. Need device confirmation on:
- [ ] Feb 10 (Vishakha Ra) — should now show ~23:51 (was "Not applicable")
- [ ] Feb 11 (Anuradha Ra) — should still be "Not applicable" (filtered correctly)
- [ ] Jan 25 (Revati Di) — should still show ~09:54 (no regression)
- [ ] Dec 17 (Vishakha Di) — should still show ~07:45 (no regression)

---

## Key Finding: Why Backward Search Doesn't Help Most MISS Entries

The 7 original MISS entries are caused by fraction mismatch (our _amritFrac ≠ Sringeri's actual
fraction for those dates), NOT by a search direction issue. The backward search correctly finds
our formula's crossing, but our targetLon differs from Sringeri's by enough that the crossing
times are ~24h apart.

The 45-minute guard ensures backward search only fires for genuine Mode B cases:
Moon is within 0.41° (45 min × 0.55°/h) of target at sunrise. This matches Dec15/Dec16 cases
(moonLon - target = 0.16° and 0.29°).

---

## Remaining Root Causes (not yet fixed)

### 1. Fraction model variance (primary — 37-min median error)
_amritFrac[] values derived from 2-4 data points per nakshatra. High variance because:
- Di amrita may be muhurtha-based (fraction of daylight), not Moon position
- Ra amrita fraction varies with Moon speed (apogee/perigee)
- Not fixable with more of the same data; needs a model change

### 2. Wrong nakshatra (Dec08/10/11) — 900-1300 min errors
Our Moon is 1.3-1.5° ahead of Sringeri's. Hypothesis: Sringeri uses MIDNIGHT as
nakshatra reference time, not sunrise. At Dec08 midnight, our Moon = 91.14° (Punarvasu);
at Dec08 sunrise = 94.74° (Pushya). Sringeri shows Punarvasu → midnight reference confirmed.
**Fix needed**: use JulianDay.fromIST(midnight) for nakshatra lookup, not sunrise.

### 3. Pre-sunrise target crossing (Dec15/16) — partially fixed
Moon crosses target 17-32 min before our sunrise. Backward search now handles these.
But delta is still -76/-65 min because Sringeri's fraction is slightly different.
**Quick fix**: raise _amritFrac for Chitra (0.82→0.84) and Swati (0.70→0.72).

---

## Session 17 — Next Steps (Priority Order)

### Step 1 — Test midnight nakshatra hypothesis (HIGHEST PRIORITY)
Write `bin/diagnose_midnight_nakshatra.dart`:
```dart
// For Dec08:
final jdSunrise = JulianDay.fromIST(DateTime(2025, 12, 8, 6, 34));
final jdMidnight = JulianDay.fromIST(DateTime(2025, 12, 8, 0, 0));
final lonSunrise = LunarPosition.siderealLongitude(jdSunrise);
final lonMidnight = LunarPosition.siderealLongitude(jdMidnight);
final nkSunrise = (lonSunrise / (360.0/27)).floor() % 27;
final nkMidnight = (lonMidnight / (360.0/27)).floor() % 27;
// Expected: nkSunrise=7 (Pushya), nkMidnight=6 (Punarvasu) → midnight hypothesis confirmed
```
If confirmed: change `panchangam_engine.dart` nakshatra lookup from `jdSunrise` to `jdMidnight`.
Then re-run validation — Dec08/10/11 errors (900-1300 min) should collapse to normal range.

### Step 2 — Adjust _amritFrac for Chitra and Swati
After Step 1 (which may affect these entries), raise:
- Chitra: 0.82 → 0.84
- Swati: 0.70 → 0.72
Re-run validation, check if Dec15/16 errors improve.

### Step 3 — Di amrita day-fraction hypothesis
Many Di amrita errors are systematic (-36 to -90 min for Feb). Hypothesis: Di amrita
fires at a fixed fraction of DAYLIGHT, not Moon position.
Test: `app/bin/test_day_fraction.py` — for each Di entry, compute (amrita-sunrise)/(sunset-sunrise).
If consistent per nakshatra+weekday → replace Moon fraction model for Di.

### Step 4 — Build + verify (after each fix)
Target after Steps 1-2: >30% within 15 min (vs current 22%)

### Step 5 — Ayanamsha toggle (user request, lower priority)
Implement both Lahiri + True Chitra Paksha in app, toggle in Settings.
See `docs/ayanamsha.md` for full design. Only after Step 1 clarifies actual root cause.

---

## Key Commands
```bash
# Validate amrita formula
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app && dart run bin/validate_amrita_formula.dart

# Build + install
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## Files Changed This Session
| File | Change |
|------|--------|
| `app/lib/core/calculations/muhurtha.dart` | Added `_searchBackward()`, modified `amritKalam()` signature |
| `app/lib/core/calculations/panchangam_engine.dart` | Added `previousSunset` computation, updated call |
| `app/bin/validate_amrita_formula.dart` | Updated call to 5-arg signature |
| `app/bin/validate_amrit.dart` | Updated call to 5-arg signature |
