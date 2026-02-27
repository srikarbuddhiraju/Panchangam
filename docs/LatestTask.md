# Latest Task — Amrit Kalam Two-Table Architecture (DONE)

**Last updated:** Feb 27, 2026
**Status:** Complete. Tests pass. Validation output correct. APK not yet rebuilt.

---

## What Was Done This Session

Implemented the proper Di.Amrita / Ra.Amrita two-table architecture (Option B from plan).

**Problem with old code:**
- Single `ghatiTable` applied all offsets from sunrise — but Sringeri Panchangam distinguishes daytime (Di.Amrita, from sunrise) and nighttime (Ra.Amrita, from sunset). Using sunrise-only for night entries causes ~40–50 min seasonal drift by summer.
- The old table had 24 entries with unverified values from an unknown source.

**What changed (3 files):**

### `app/lib/core/calculations/muhurtha.dart`
- Replaced single `ghatiTable` (27 ghati ints) with two parallel `List<int?>` arrays storing **minutes**:
  - `_dayOffset` — minutes from sunrise for Di.Amrita entries
  - `_nightOffset` — minutes from sunset for Ra.Amrita entries
- Updated `amritKalam()` signature: added `sunset` parameter
- Only 4 Sringeri-verified entries populated; all 23 others are null

### `app/lib/core/calculations/panchangam_engine.dart`
- Line 82: added `sunset` to `Muhurtha.amritKalam()` call

### `app/bin/validate_amrit.dart`
- Line 32: extracted `sunset = times[1]`, added to call

---

## Verified Entries (Sringeri Panchangam)

| Nakshatra | # | Type | Offset | Minutes |
|-----------|---|------|--------|---------|
| Ardra     | 6 | none | —      | null (explicit "అమృతఘటికాభావ") |
| Vishaka   | 16 | Di.Amrita | sunrise + 501 min | 20gh53v |
| Mula      | 19 | Ra.Amrita | sunset + 449 min  | 18gh42v |
| Purva Ashadha | 20 | Ra.Amrita | sunset + 682 min | 28gh25v |

---

## Validation Output (dart run bin/validate_amrit.dart)

```
16  విశాఖ    2026-03-09  06:28  14:49 – 16:25   ← sunrise + 501 min ✓
19  మూల      2026-03-12  06:26  01:54 – 03:30   ← sunset + 449 min ✓
20  పూర్వాషాఢ 2026-03-13  06:25  05:47 – 07:23  ← sunset + 682 min ✓
 6  ఆర్ద్ర   2026-02-27  06:35  Not applicable  ← confirmed null ✓
all others:  Not applicable                      ← pending Sringeri data ✓
```

---

## Test Results

All 32 tests pass. `dart analyze` — no errors.

---

## To Do For Next Session

### Amrit Kalam (still in progress)
1. **Full table verification** — 23 nakshatras still null (unverified). Need to read more Sringeri PDF entries.
   - Ask Srikar for page numbers in Sringeri PDF covering remaining nakshatras.
   - For each: note Di/Ra type and the offset in ghati+vipala, convert to minutes.
   - Source priority: Sringeri (1st) → TTD (2nd) → DrikPanchang (3rd).
2. **Rebuild APK** — changes not yet on device. Run:
   ```bash
   cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
   /home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
   /home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
3. Srikar spot-checks Vishaka, Mula, Purva Ashadha on device.

### Sringeri Disclaimer (pending)
- Add note in app: "Calculations based on Sringeri Panchangam, supervised by the Sringeri Matha."
- Discuss placement with Srikar (Settings / About / footer).

### Known Bug — Festival/Eclipse Not Loading on Launch
- Festivals/eclipse highlights missing on initial calendar page load.
- User must navigate away and back for them to appear.
- Root cause: provider initialization timing (data not ready when grid first renders).

### Improper festivals — Fix immediately
- Vaikunta Ekadashi shows Dec 1 (should be Dec 30, 2025)
- Diwali date also wrong
- Re-validate all Grahanam timings (AM/PM, sub-timings)

### MVP Checklist Session
- After Amrit Kalam table is complete: full MVP review with Srikar.
- Includes: dark mode, Family tab decision, Play Store account, UX refinement.
