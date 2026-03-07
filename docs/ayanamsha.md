# Ayanamsha Calibration — Research & Findings

**Branch:** `feature/ayanamsha-calibration`
**Last updated:** Session 15 (Mar 7, 2026)

---

## What We Use

`app/lib/core/calculations/ayanamsa.dart` — Lahiri ayanamsha:
- Epoch: J1900.0 (JD = 2415020.0)
- Value at epoch: 22°27'37.74" = 22.46055556°
- Rate: 50.2388475 arcsec/year (linear approximation)
- At Jan 2026: ~24.219°

## What Sringeri Uses

**True Chitra Paksha** (also called Chitrapaksha) — the astronomically correct version:
- Defined as: ayanamsha = tropical longitude of Spica (α Virginis) − 180°
- Computed dynamically using precise Spica position (proper motion + precession)
- Used in Swiss Ephemeris (SE_SIDM_TRUE_CHITRA), Jagannatha Hora

## Are They the Same?

**Lahiri is an approximation of Chitra Paksha** — confirmed by both computation and user.

Quantified difference (user-provided reference data):
| Date | Chitra Paksha | Lahiri | Difference |
|------|--------------|--------|------------|
| 1 Jan 1900 | 22°26'45.50" | 22°27'37.74" | 52.24" |
| 1 Jan 2026 | ~24.204° | ~24.219° | **~57" ≈ 1 arcminute** |
| 1 Jan 10000 | 137°13'57.73" | 137°20'17.34" | 6'19.61" |

**Key insight**: Lahiri drifts ~0.04"/year faster than True Chitra Paksha (accumulated
from 1900 due to linear vs nonlinear precession + Spica proper motion).

### Impact on Timing

At Moon speed ~0.55°/h:
- 57" difference = 0.01583° → **1.7 minutes timing error**
- This is within our 5-minute accuracy target
- Not the cause of our 37-minute median error

### Conclusion

**Ayanamsha is NOT the root cause of our accuracy problems.** The 1.7-min contribution
is meaningful for final 5-min precision but irrelevant while we have 37-min errors.

---

## True Root Causes of 22% Accuracy

### Cause 1: Fraction model variance (primary — causes 37-min errors)

The `_amritFrac[]` table assumes amrita fires at a *fixed fraction* through nakshatra.
But Moon speed varies (apogee 0.49°/h, perigee 0.61°/h). If amrita fires at a **fixed
TIME** from nakshatra entry, then:
- Fast Moon → traverses more fraction in same time → higher fraction at amrita
- Slow Moon → lower fraction
This explains observed variance: Mula 66–71%, Mrigashirsha 57–76%, etc.

**Hypothesis to test**: Does `time_since_nk_entry_min` have lower variance than
`lon_frac` per nakshatra? If yes → switch to time-offset model.

### Cause 2: "Already past target" logic (causes 900+ min errors)

Dec08 (+913), Dec10 (+1077), Dec11 (+1013), Dec15 (+1348):
- At sunrise, Moon is near END of the nakshatra, already past the target fraction
- Code tries next nakshatra (attempt=1) → fires 18-24h later
- Fix: detect this case and search BACKWARD for the crossing before sunrise

### Cause 3: Pre-sunrise Ra amrita (7 MISS entries)

Moon reaches target fraction BEFORE sunrise. Forward search finds nothing.
Backward search (tried before) found PREVIOUS lunar cycle's crossing (~24h too early).
Fix: backward search with validation T_amrita > yesterday's sunset.

---

## Drik Ganitha vs Vakya

From advaita-l discussion (Apr 2016):
- **Drik Ganitha**: sky-based, uses modern astronomical formulae (what we use)
- **Vakya**: traditional tabular method from Surya Siddhanta / cyclic corrections
- Sringeri likely uses Drik Ganitha with True Chitra Paksha ayanamsha

This means our Moon position calculation (Meeus Ch. 47) and Sringeri's should agree
to within ±0.003° (our stated accuracy). The ayanamsha is the only meaningful difference,
and it's only ~1 arcminute.

---

## User Feature Request — Dual Ayanamsha Toggle (Session 15)

**Request**: Implement both Lahiri and True Chitra Paksha in the app. Use the right
ayanamsha per calculation type. If unknown, provide a user toggle in Settings.

**Design**:
```dart
enum AyanamshaMode { lahiri, trueChitraPaksha }

class Ayanamsa {
  static double lahiri(double jd) { ... } // existing
  static double trueChitraPaksha(double jd) {
    // Compute Spica's actual tropical longitude using Meeus star catalog
    // ayanamsha = spicaTropicalLon - 180°
    // Differs from Lahiri by ~57" = 1.7 min in 2026
  }
  static double current(double jd, AyanamshaMode mode) { ... }
}
```

**Settings screen**: Dropdown with explanation:
- "Lahiri (Govt of India standard)" — linear formula, widely used
- "True Chitra Paksha" — dynamic Spica-based, astronomically precise, Swiss Ephemeris

**Store in**: SharedPreferences → `ayanamsha_mode` key

**Priority**: Implement AFTER resolving the 1.3-1.5° Moon gap (which is NOT explained
by Lahiri vs Chitra Paksha — likely Sringeri uses midnight nakshatra reference or Vakya tables).

**Known impact**: 1.7 min timing difference on amrita kalam. Minor for 5-min target.
Affects all sidereal calculations (nakshatra, tithi, rashi) equally.

---

## Investigation Plan (feature/ayanamsha-calibration branch)

### Phase 1 — Test time-offset hypothesis
Script: `app/bin/time_offset_analysis.py` (Agent A running)
- Compare per-nakshatra CV of lon_frac vs time_since_nk_entry_min
- If time CV < frac CV → hypothesis confirmed, switch models

### Phase 2 — Fix boundary errors
Script: `app/bin/diagnose_boundary_errors.dart` (Agent B running)
- Trace Dec08/10/11/15 sunrise Moon positions
- Design backward-search fix

### Phase 3 — Fix MISS cases
Proposal: `docs/data/miss_fix_proposal.dart` (Agent C running)
- Backward search with yesterday's-sunset validation gate

### Phase 4 — Rebuild _amritFrac or _amritOffset table
- If time model confirmed: derive `_amritOffset[27]` (minutes from nk entry)
- Use full 391 OCR entries + re-derive with more data

### Phase 5 — Ayanamsha fine-tuning (last)
- After Phase 1-4, if residual error ~2 min, adjust ayanamsha by -0.016° (True Chitra)
- Expected improvement: 1.7 min → achieves 5-min target

---

## Key Reference Values

- Moon mean speed: 0.549°/h (varies 0.49–0.61°/h)
- Nakshatra span: 360/27 = 13.333...° (use 360.0/27 in code)
- Amrita duration: 4 ghatikas = 96 minutes (fixed)
- Validation set: 69 entries in `app/bin/validate_amrita_formula.dart`
- OCR data: 391 entries in `docs/data/amrita_2526.csv`
