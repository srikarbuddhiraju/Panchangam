# Latest Task — Amrit Kalam Fix (IN PROGRESS)

**Last updated:** Feb 23, 2026
**Status:** Mostly done — Ardra null confirmed correct, Mula fixed. Ghati table still needs full verification. APK not yet rebuilt after last fix.

---

## What Was Done

Replaced the old fake amritKalam() in `muhurtha.dart` with a ghati-based calculation.
Formula: `start = sunrise + ghati * 24 minutes`, duration = 96 minutes (4 ghatis).
Made `amritKalamStart` / `amritKalamEnd` nullable (`DateTime?`) throughout the stack.
Added "Not applicable" display string in `app_strings.dart`.
Updated `muhurtha_card.dart` to show "Not applicable" when null.

---

## Findings From Sringeri Panchangam PDF

Srikar shared two PDFs in `docs/Ref Panchangam/`:
- **Sringeri Panchangam** (5.9MB) — Visvavasu 2025-26, Telugu full text with daily entries
- **TTD Panchangam** (14.9MB) — also Visvavasu 2025-26

From reading daily entries around page 109 of Sringeri PDF:

- **Ardra (Jan 27)**: Entry says "అమృతఘటికాభావ" = explicitly "no amrit ghati". Ardra null IS CORRECT.
- **Mula (Jan 13)**: Entry says "రా.అమ్రుత" and shows time ~8:30–10:16 AM. Mula DOES have amrit kalam.
  - Sunrise on Jan 13 ≈ 6:56 AM. Amrit start ≈ 8:30 AM → offset ≈ 94 min ÷ 24 = ~4 ghatis.
  - **Fixed**: Mula changed from null → 4.

---

## Current Ghati Table (in muhurtha.dart — PARTIALLY VERIFIED)

```dart
const List<int?> ghatiTable = [
  16, 14, 23, 50, 54,   // 1-5:  Ashwini, Bharani, Krittika, Rohini, Mrigashirsha
  null, 17, 30, 52, 47, // 6-10: Ardra(none ✓ confirmed), Punarvasu, Pushya, Ashlesha, Magha
  20, 18, 45, 33, 60,   // 11-15: Purva Phalguni, Uttara Phalguni, Hasta, Chitra, Swati
  10, 27, 43, 4, 24,    // 16-20: Vishakha, Anuradha, Jyeshtha, Mula(4 estimated), Purva Ashadha
  53, 40, 37, 55, 8,    // 21-25: Uttara Ashadha, Shravana, Dhanishtha, Shatabhisha, Purva Bhadrapada
  28, 48,               // 26-27: Uttara Bhadrapada, Revati
];
```

**Known issues:**
- Mula ghati=4 is estimated from ONE data point — verify from more Sringeri entries
- Bharani discrepancy: our code gives 12:14 PM, Sringeri shows 12:47 PM for Feb 23 → Bharani ghati may be 15-16 not 14
- Full table not yet verified against PDF (only Ardra and Mula confirmed)

---

## Files Changed (already saved, tests pass)

- `app/lib/core/calculations/muhurtha.dart` — amritKalam() method (ghati table here)
- `app/lib/core/calculations/panchangam_engine.dart` — nullable amritKalamStart/End fields + call site
- `app/lib/core/utils/app_strings.dart` — added `notApplicable` string
- `app/lib/features/panchangam/widgets/muhurtha_card.dart` — null check + invalidMessage param

---

## Validated Data Points (from Sringeri Panchangam + DrikPanchang)

| Date | Nakshatra | Source | Status |
|------|-----------|--------|--------|
| Jan 13 | Mula (19) | Sringeri PDF | 8:30-10:16 AM (ghati≈4) |
| Jan 27 | Ardra (6) | Sringeri PDF | "అమృతఘటికాభావ" = null ✓ |
| Feb 23 | Bharani (2) | DrikPanchang | ~12:01 PM (our code: 12:14 PM) |
| Mar 3 | Magha (10) | DrikPanchang | ~1:13 AM next day |
| Mar 8 | Swati (15) | DrikPanchang | ~6:25 AM next day |

---

## Next Session Steps

1. **Rebuild APK** — last fix (Mula null→4) not yet deployed to phone
2. **Full ghati table verification** — read more Sringeri daily entries, cross-check all 27 nakshatras
3. Bharani in particular needs re-check (15-16 instead of 14?)
4. Run `dart analyze` + `dart test` before APK build
5. Srikar spot-checks on device

---

## To Do For Next Session (MVP Checklist)

### Amrit Kalam (current task)
1. **Verify full ghati table** — ask Srikar for specific page numbers in Sringeri/TTD PDFs for each nakshatra. Do NOT read full PDF. Source priority: Sringeri (1st) → TTD (2nd) → DrikPanchang (3rd).
2. **Bharani re-check** — our code: 12:14 PM, expected ~12:47 PM. Bharani ghati likely 15–16, not 14. Ask for page with a Bharani day entry.
3. **Mula re-check** — ghati=4 estimated from one data point (Jan 13). Ask for another Mula day entry to confirm.
4. **After table correction** — run `dart test`, rebuild APK, push to phone, Srikar spot-checks.

### Sringeri Disclaimer (new task)
- Add a note/disclaimer in the app: "Calculations based on Sringeri Panchangam, the authoritative traditional source supervised by the Sringeri Matha."
- Discuss with Srikar where to place it (Settings screen? About section? Footer on Panchangam screen?).

### Known Bug — Festival/Eclipse Not Loading on Launch
- Festivals and eclipse highlights do not appear on the calendar landing page at app launch.
- User must navigate to next/previous month first, then they appear.
- Root cause: likely a provider initialization timing issue (data not ready when grid first renders).
- Fix needed before release.

### Improper festivals - Rectify calculations immediately
- The last Vaikunta Ekadashi fell on 30th December 2025, in our app it shows 1st December, rectify it.
- Same as above point, Diwali fell in December, which is wrong.
- Re-validate all Grahanam timings, check sub timings, AM PM inconsistencies. 

### MVP Checklist Session
- After Amrit Kalam verified: sit down with Srikar and review full MVP checklist together.
- Includes: dark mode validation, Family tab decision, Play Store account, UX refinement session.

---

## How to Rebuild APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
