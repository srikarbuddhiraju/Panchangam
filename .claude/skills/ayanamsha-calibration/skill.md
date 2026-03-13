# Skill: Amrita Kalam Calibration

**Goal**: Bring amrita kalam accuracy to ≤5 min vs Sringeri Panchangam (current: 22%, 37-min median error).

**Branch**: `feature/ayanamsha-calibration`
**Validation script**: `dart run bin/validate_amrita_formula.dart` (69 Sringeri entries, Dec 2025–Mar 2026)
**Reference file**: `app/lib/core/calculations/muhurtha.dart`

---

## CRITICAL FACTS — Read This First

### Ayanamsha: MINOR contribution only (~1.7 min) — VERIFIED
- We use **Lahiri** (J1900 epoch, 22°27'38", rate 50.2388"/year)
- **Sringeri uses True Chitra Paksha** (dynamic Spica-based, Swiss Ephemeris style)
- Quantified difference: Lahiri − True Chitra = **~57 arcsec (~1 arcminute) in 2026**
- Timing impact: **1.7 minutes** — NOT the cause of 37-min errors
- Lahiri drifts faster than True Chitra by ~0.04"/year (accumulated from 1900)
- User-verified reference: Chitra at 1900=22°26'45.5", Lahiri at 1900=22°27'37.7"
- The 1.7 min matters only AFTER the primary 37-min model error is fixed
- Source: `app/lib/core/calculations/ayanamsa.dart` — do not change until Phase 2

### Why fraction model gives 22% accuracy
The `_amritFrac[]` table assumes amrita fires when Moon reaches a FIXED fraction through nakshatra.
This is an approximation. Mathematically:
- Fraction through nakshatra = (moon_lon - nk_start) / nk_span
- This fraction is INVARIANT under ayanamsha shift — ayanamsha cannot fix it
- Observed variance: Mula = 66-71%, Mrigashirsha = 57-76%, Anuradha = 57-61%
- At Moon speed ~0.55°/h and nk_span = 13.333°, 5% variance = 73 min timing error

### Why the fraction varies (the real root cause)
Moon's orbital speed varies (~0.49°/h at apogee to ~0.61°/h at perigee).
If amrita fires at a **fixed TIME offset** from when Moon enters the nakshatra:
- Fast Moon → traverses more fraction in the same time → higher fraction at amrita
- Slow Moon → traverses less fraction → lower fraction at amrita
- This perfectly explains the observed variance: it's not noise, it's Moon speed

**HYPOTHESIS (untested as of Session 14)**: Amrita fires at a fixed number of minutes after Moon enters the nakshatra, not at a fixed fraction.

If true: `amrita_start = nk_entry_time + K_nk` where K_nk is a constant per nakshatra (in minutes).

---

## What Was Tried — DO NOT Repeat These

### 1. ML pipeline on OCR data (FAILED — 6-8% accuracy)
- 4-stage ML: mean frac → linear regression on moonSpeed → Random Forest → Dart output
- Stage 1 got 6%, Stage 2 (linear) got 8%, Stage 3 (RF) got 2%
- **Why it failed**: ML trained on OCR nk_idx (sunrise nakshatra) which may not match the nakshatra at amrita time; ayanamsha thought to be the cause (later disproved)
- Clean data (315 entries after outlier filter) gave same result
- **Do not rerun ML on fraction as target variable**

### 2. Pre-sunrise Ra amrita fallback (FAILED)
- Tried to catch Ra amrita that fires at 1-5 AM by searching before sunrise
- Found the PREVIOUS lunar cycle's crossing (~24h too early)
- The bisection runs from `jdSearch - 1` to `jdSearch + 1` but finds the backward crossing
- **Fix needed**: proper backward-then-forward search with cycle detection

### 3. Recompute nkIdx from Moon longitude at amrita time (FAILED — made things worse)
- Changed `compute_ml_features.dart` to use `nkNum - 1` (Moon's actual nakshatra at amrita) instead of OCR nk_idx (sunrise nakshatra)
- 51% mismatch between OCR nakshatra and our recomputed nakshatra
- Root cause thought to be ayanamsha (later disproved — both are Lahiri; mismatch is real)
- REVERTED — `compute_ml_features.dart` currently outputs OCR nk_idx

### 4. Hand-tuned _amritFrac[] table (CURRENT — 22% ceiling)
- 27 values derived from Dec 2025, Jan 2026, Mar 2026 data (41 entries)
- Gives 22% within 15 min, 37-min median error
- Cannot improve beyond ~25-30% without addressing fraction variance
- **Do not add more entries to this table without fixing the model**

---

## SESSION 15 FINDINGS — Read Before Starting Work

### Finding 1: Ayanamsha is NOT the primary issue (confirmed)
- Lahiri vs True Chitra Paksha: only 57" = 1.7 min timing difference
- Sringeri confirmed to use True Chitra Paksha
- This 1.7 min matters only in Phase 2 (fine-tuning)

### Finding 2: Time-offset model NOT better than fraction model
- Both have ~39% CV per nakshatra (Agent A, Mar 7 2026)
- Time wins 9/25 nakshatras, frac wins 2/25 — marginal
- Ra amrita is more predictable (35% CV) than Di amrita (43% CV)
- DO NOT switch to time-offset model — no benefit

### Finding 3: Two distinct boundary failure modes (Agent B, Mar 7 2026)
**Mode A — Wrong nakshatra (Dec08, 10, 11):**
- Our Moon is ~1.3-1.5° AHEAD of Sringeri's for these dates
- At Dec08 sunrise: our Moon at 94.74° (Pushya), Sringeri sees Punarvasu (<93.333°)
- Gap is 1.41°+ — FAR too large to be Lahiri vs Chitra Paksha (only 0.016°)
- **Must investigate JulianDay.fromIST() for timezone bug first**
- Hypothesis: if IST→UT conversion is off by ~2.7h, Moon would be 1.48° ahead

**Mode B — Pre-sunrise target crossing (Dec15, 16):**
- Correct nakshatra, but Moon crosses _amritFrac target 15-32 min before our sunrise
- Gap: 0.16° (Dec15 Chitra) and 0.29° (Dec16 Swati)
- Sringeri's slightly different ayanamsha puts crossing just after THEIR sunrise
- Quick fix: raise _amritFrac for Chitra (0.82→0.84) and Swati (0.70→0.72)

### Finding 4: MISS fix fully designed (Agent C, Mar 7 2026)
- Code written in `docs/data/miss_fix_proposal.dart` — ready to copy into muhurtha.dart
- Backward bisection: window [jdSunrise-27h, jdSunrise], validated against previousSunset
- Requires new `previousSunset` parameter in amritKalam() signature
- Jan29 Mrigashirsha Ra (20:02) is a DIFFERENT issue — needs separate diagnosis

### Finding 5: Di amrita may be muhurtha-based (hypothesis)
- Di amrita fires at specific muhurtha (1/15 of daylight) per nakshatra+weekday
- Evidence: Krittika Dec04 Thu day_frac=0.550, Feb24 Tue day_frac=0.572 (close!)
- This would explain why Di CV (43%) is higher than Ra CV (35%)
- Test: `app/bin/test_day_fraction.py` — compute (amrita-sunrise)/(sunset-sunrise) per entry

---

## The Correct Investigation Path

### Phase 1 — Test the time-offset hypothesis
Create `app/bin/test_amrita_time_offset.dart`:
```dart
// For each OCR/validated entry:
// 1. Compute nk_entry_time (when Moon entered the nakshatra at amrita)
//    — use nkEntryTime() from compute_ml_features.dart
// 2. Compute time_offset_min = amrita_start - nk_entry_time
// 3. Group by nakshatra, compute mean and std dev of time_offset_min
// 4. Compare: is std_dev(time_offset_min) < std_dev(lon_frac × nk_duration)?
// If yes → time model is better than fraction model
```

Expected result if hypothesis is correct:
- Frac std dev per nakshatra: ~3-5% (observed)
- Time offset std dev per nakshatra: <10 min (to be measured)
- A std dev of <8 min would give formula accuracy of ±8 min (±1σ)

### Phase 2 — Build new formula
If time-offset model confirmed:
```dart
// In muhurtha.dart:
static const List<int?> _amritOffset = [
  // minutes from nakshatra entry to amrita start, per nakshatra (1-based, 0-indexed)
  // null = no data
  null, // 1 Ashwini
  // ... derived from Phase 1 analysis
];

static List<DateTime>? amritKalam(...) {
  // 1. Find when Moon enters the sunrise nakshatra (backward search from sunrise)
  // 2. amritaStart = nkEntryTime + _amritOffset[nkIdx]
  // 3. If amritaStart < sunrise → try next nakshatra
  // 4. Apply bounds checks
}
```

### Phase 3 — Handle boundary / MISS cases
The 7 MISS cases (Ra amrita before sunrise) require:
- Find nk entry time BEFORE sunrise (Moon entered nakshatra yesterday)
- Compute amrita_start = yesterday_nk_entry + offset
- If this falls before today's sunrise but after yesterday's sunset → it's a valid Ra amrita
- Show on the PREVIOUS day, or show "Ra amrita at HH:MM" on the boundary day

### Phase 4 — Validate
- Run `dart run bin/validate_amrita_formula.dart`
- Target: >60% within 15 min (Phase 4 goal), stretch: >80%
- Verify no regression on the 15 currently-OK entries

---

## Key Files

| File | Purpose |
|------|---------|
| `app/lib/core/calculations/muhurtha.dart` | Formula + _amritFrac table (edit here) |
| `app/lib/core/calculations/ayanamsa.dart` | Lahiri formula (do not change) |
| `app/lib/core/calculations/lunar_position.dart` | Moon position (Meeus Ch. 47, do not change) |
| `app/bin/validate_amrita_formula.dart` | 69-entry validation (always run after changes) |
| `app/bin/compute_ml_features.dart` | Feature engineering (has nkEntryTime() — reuse) |
| `docs/data/amrita_2526.csv` | 391 OCR entries (source data for derivation) |
| `docs/data/ml_features.csv` | Pre-computed features for 391 entries |

---

## Mathematician's Checklist (run before any code change)
- [ ] Prove the formula gives the right answer for 2 known entries by hand (pen-paper or Dart print)
- [ ] Verify the model assumption holds: check variance of the proposed target variable per nakshatra
- [ ] Ensure no 360°/0° wraparound bugs in bisection or backward search
- [ ] Verify boundary condition: what happens when Moon is at 0% of nakshatra at sunrise?
- [ ] Verify boundary condition: what happens when amrita fires BEFORE sunrise?

## Astronomer's Rules
- Moon's speed: 0.49°/h (apogee) to 0.61°/h (perigee), mean ~0.549°/h
- Nakshatra span: 360/27 = 13.333... degrees (exact fraction — use 360.0/27 in code)
- Moon traverses one nakshatra in ~20h (fast) to ~27h (slow), mean ~24.4h
- Ayanamsha (2025-26): ~24.2° Lahiri — both we and Sringeri use this
- JD precision: 1 minute = 1/(24×60) = 0.000694 JD — always use double

## Traditional Astrologer's Rules
- Amrita Kalam = 4 ghatikas = 96 minutes duration (FIXED, do not change)
- Di.Amrita = daytime amrita (sunrise to sunset)
- Ra.Amrita = night amrita (sunset to next sunrise, can cross midnight)
- అమృతఘటికాభావ = no amrita (must show "Not applicable" — currently correct)
- Nakshatra at amrita is the ONE printed in the Panchangam for that sunrise

## App Developer's Rules
- NEVER change global ayanamsha in ayanamsa.dart for amrita-only fixes
- NEVER modify validate_amrita_formula.dart entries — they are ground truth
- Always run `flutter build apk --release` before marking any session complete
- Install on device (10BDAH07CM000MQ) and verify on Feb 10, 11, 26 (known MISS) and Feb 22, Jan 25 (known OK)
- The device shows "Not applicable" for null returns — make sure this is intentional for each null
- Do not break the other 15 OK entries while fixing the 54 not-OK

## Error Pattern Reference (from validation)
```
Dec08 Punarvasu  +913 min  — Moon past target, jumped to wrong nakshatra
Dec10 Ashlesha  +1077 min  — same (nakshatra boundary anomaly)
Dec11 Magha     +1013 min  — same
Dec15 Chitra    +1348 min  — same
Feb13-Feb25 Di  -36 to -90 min  — systematic: fraction model fires early
Feb11 Anuradha  MISS        — Ra amrita at 03:22 AM (before sunrise)
Jan26 Ashwini   MISS        — Ra amrita at 04:44 AM (before sunrise)
Jan29 Mrgshr    MISS        — Ra amrita before sunrise
Feb26 Mrgshr    MISS        — Ra amrita at 01:27 AM (before sunrise)
```
The +913/+1077 anomalies: code jumped to next nakshatra (attempt 2) and found a time ~24h away.
These will be fixed if the time-offset model is correct (no nakshatra jumping needed).
