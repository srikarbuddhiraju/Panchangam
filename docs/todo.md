# Session 19 — Implement Surya Siddhanta Moon

**Branch:** `feature/ayanamsha-calibration`
**Goal:** Replace Drik Moon with Surya Siddhanta Moon inside amritKalam() → match Sringeri Panchangam.

---

## Why

Sringeri Panchangam title explicitly states "సూర్యసిద్ధాంత పంచాంగము" (Surya Siddhanta Panchangam).
The Surya Siddhanta Moon uses a smaller equation-of-center (~5.02° max vs Meeus ~6.29° max),
causing Moon positions that differ from Drik by ~1–2° in the current era.
At Moon speed ~0.009°/min, 1.2° = ~133 min timing difference — matches our observed errors exactly.

The formula architecture (Moon-fraction bisection) is CORRECT. Only the Moon ephemeris is wrong.

---

## What NOT to change

- Displayed nakshatra in the calendar → stays Drik (VSOP87, accurate)
- Tithi, yoga, karana, sunrise/sunset → all stay Drik
- `_amritFrac[]` values → will be recalibrated but structure stays the same
- The bisection logic in `amritKalam()` → untouched except which Moon to call

---

## Step 1 — Implement `SuryaSiddhantaMoon` class

**File:** `app/lib/core/calculations/surya_siddhanta_moon.dart`

**Constants from the Surya Siddhanta text:**
```
Kali Yuga epoch:       JD 588465.5  (Feb 17, 3102 BCE, proleptic Julian Calendar)
Mahayuga civil days:   1,577,917,828
Moon revolutions:      57,753,336  per Mahayuga
Moon apogee revs:      488,219     per Mahayuga
```

**Derived daily motions:**
```
Moon mean motion  = 57,753,336 / 1,577,917,828 × 360° = 13.17634906°/day
Apogee motion     = 488,219    / 1,577,917,828 × 360° = 0.11140365°/day
```

**Moon's true longitude:**
```
elapsed = jd − 588465.5                              (Kali days from epoch)
meanMoon = elapsed × 13.17634906°                    (normalized to 0–360)
meanApogee = elapsed × 0.11140365°                   (normalized to 0–360)
anomaly = meanMoon − meanApogee                      (manda anomaly)
mandaCorrection = arcsin(31.5/360 × sin(anomaly))    (equation of center, degrees)
trueMoon = meanMoon + mandaCorrection                 (normalized to 0–360)
```

**Sidereal conversion:**
```
siderealLon = trueMoon − Ayanamsa.lahiri(jd)         (same Lahiri as current)
```

**Method signature** (drop-in replacement for `LunarPosition.siderealLongitude()`):
```dart
static double siderealLongitude(double jd) → degrees
```

---

## Step 2 — Validate SS Moon fractions (before touching muhurtha.dart)

**File:** `app/bin/validate_ss_moon.dart`

For each of 124 Sringeri reference entries:
- Compute SS Moon longitude at Sringeri reference time
- Compute fraction within the nakshatra: `frac = (ssLon % nkSpan) / nkSpan`
- Print side-by-side: Sringeri time, Drik frac, SS frac, nakshatra

**What we're checking:**
- Do same-nakshatra entries now show CONSISTENT fractions across months?
  - If yes: SS Moon explains the variation → model will work
  - If no: SS Moon alone is not the full picture → investigate further before touching muhurtha.dart

**Do NOT update muhurtha.dart until this script confirms consistency.**

---

## Step 3 — Recalibrate `_amritFrac[]` using SS Moon

**File:** update `app/bin/calibrate_amrit_frac.dart`
- Change `LunarPosition.siderealLongitude()` → `SuryaSiddhantaMoon.siderealLongitude()`
- Re-run to get new mean fractions per nakshatra
- Remove the nakshatra-match filter (it was needed for Drik-Vakya mismatch; SS should match Sringeri natively)

---

## Step 4 — Update `muhurtha.dart`

**File:** `app/lib/core/calculations/muhurtha.dart`

Two changes only:
1. Add import: `import 'surya_siddhanta_moon.dart';`
2. Replace both `LunarPosition.siderealLongitude(...)` calls with `SuryaSiddhantaMoon.siderealLongitude(...)`
   - Line ~172: nakshatra detection at search start
   - Line ~202: bisection loop

Update `_amritFrac[]` values with recalibrated SS-based fractions.
Update the comment block (source, accuracy, derivation).

---

## Step 5 — Re-run validation

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart run bin/validate_amrita_formula.dart
```

**Target:** >50% within 15 min across all 124 entries (up from 14.5%)
**Stretch:** >70% within 15 min

If target NOT met: diagnose which nakshatras still fail before building APK.

---

## Step 6 — Build + Install

```bash
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```

- [ ] Amrita time on device matches Sringeri within 15 min for today

---

## Step 7 — Commit + Merge

```bash
git add app/lib/core/calculations/surya_siddhanta_moon.dart
git add app/lib/core/calculations/muhurtha.dart
git add app/bin/validate_amrita_formula.dart app/bin/calibrate_amrit_frac.dart
git add docs/
git commit -m "feat(amrita): use Surya Siddhanta Moon in amritKalam for Sringeri accuracy"
git checkout main && git merge feature/ayanamsha-calibration && git push
```

---

## Risk / Fallback

If SS Moon fractions are still inconsistent (Step 2 fails):
- The Sringeri authors may be using bija-corrected SS tables — additional correction terms not in the base text
- Fallback: compute the empirical SS-Drik offset from the 124 data points, fit as a function of Moon anomaly, apply as a correction
- This is Option C (data-driven correction) as a fallback, not Option A

## Key file references
- `app/lib/core/calculations/muhurtha.dart` — lines ~172 and ~202 are the only changes
- `app/lib/core/calculations/surya_siddhanta_moon.dart` — NEW file
- `app/bin/validate_ss_moon.dart` — NEW validation script
- `app/bin/validate_amrita_formula.dart` — already updated with 124 entries
- `app/bin/calibrate_amrit_frac.dart` — update Moon model
