# Latest Task — Session 12 In Progress

**Last updated:** Mar 6, 2026
**Branch:** feature/amrita-moon-fraction-formula

---

## What's Done (Sessions 1–11)

Sessions 1–11 all complete. See git log for full history.
Session 11: OCR'd Dec 2025 + Mar 2026 Sringeri data, confirmed 27×7 table is architecturally wrong.

---

## Session 12 — Amrita Kalam Formula Replacement

### Completed this session
- [x] Tried Chaldean planetary hora system — FAILED (65–714 min wrong)
- [x] Ran `amrita_pattern.dart`: discovered Moon fraction at amritaStart is consistent per nakshatra
- [x] Key insight: formula is 1D (nakshatra → target fraction), NOT weekday-dependent
- [x] Built 27-entry `_amritFrac[]` table from Dec 2025 + Jan 2026 + Mar 2026 data (41 entries)
- [x] Rewrote `amritKalam()` in `muhurtha.dart`: bisection search for Moon target longitude
- [x] Fixed Revati wraparound bug; extended search window to 26h
- [x] Created `bin/validate_amrita_formula.dart` (now 69-entry after Feb data added)
- [x] `dart analyze` — no errors
- [x] Release APK builds: 58.8 MB
- [x] OCR'd February 2026 Sringeri Panchangam (Sarvam AI, te-IN):
  - Jan 29–Feb 17: from printed pages 110–111 (job from prior context)
  - Feb 18–28: from printed pages 111–112 (job 20260306_e7f7f5b4, this session)
- [x] Computed exact offsets for all Feb entries via Dart SunriseSunset calculator
- [x] Saved to `docs/data/sringeri_feb2026_raw.md` and `docs/data/sringeri_feb2026_parsed.md`
- [x] Added 29 new Feb entries to `validate_amrita_formula.dart` (total: 69 entries)
- [x] Updated `amrita_pattern.dart` with full Feb data
- [x] Updated `_amritFrac[23]` = 0.51 (Shatabhisha — was null, now has Feb18 data point)

### Validation results (before _amritFrac update)
| Category | Before (41 entries) | After Feb added (69 entries) |
|---|---|---|
| OK (≤15 min) | 22/41 (54%) | 22/69 (32%) |
| MISS (null) | 6 | 14 |
| WARN/FAIL (>15 min) | 13 | 33 |

**Root cause of Feb failures**: `_amritFrac[]` was fitted only on Dec/Jan/Mar data.
Feb data shows DIFFERENT clock times for same nakshatras → fractions need re-averaging with Feb data.
Need to run `bin/amrita_pattern.dart` to get updated per-nakshatra fractions.

### Key Feb 2026 findings
- **Feb 12, Feb 27**: No amrita (`అమృతఘటికాభావ`)
- **Feb 25, Feb 28**: Both Di AND Ra amrita exist (formula returns Di only)
- **Shatabhisha (nk=24)**: First data point — Feb18 Di off=469 → fraction ~0.79
- **Ardra (nk=6)**: Jan30 Di (off=634, late afternoon), but Feb27 = no amrita — high variance
- **Shravana (nk=22)**: Feb16 Di off=183 (09:45 AM) vs Mar15 Di off=656 (17:19 PM) → very different clock times but same Moon fraction (to be verified by pattern script)

---

## To Do For Next Session

- [ ] Run `bin/amrita_pattern.dart` to compute Moon fractions for ALL 69 entries per nakshatra
- [ ] Update `_amritFrac[]` in `muhurtha.dart` using averaged fractions across all months
- [ ] Re-run `bin/validate_amrita_formula.dart` — expect significant improvement
- [ ] Install APK on device (`10BDAH07CM000MQ`) and visually verify Amrita Kalam
- [ ] Merge `feature/amrita-moon-fraction-formula` → main
- [ ] Update MVP checklist

---

## Key Files Changed This Session
- `app/lib/core/calculations/muhurtha.dart` — full rewrite of `amritKalam()`
- `app/bin/validate_amrita_formula.dart` — 69-entry validation script
- `app/bin/amrita_pattern.dart` — updated with full Feb data (69 entries)
- `docs/data/sringeri_feb2026_raw.md` — new, raw OCR for full Feb
- `docs/data/sringeri_feb2026_parsed.md` — new, parsed entries + offsets
- `docs/data/sringeri_jan2026.txt` — confirmed Jan 2026 (Jan16-28 not yet in validate script)

## Rebuild + Reinstall APK
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
