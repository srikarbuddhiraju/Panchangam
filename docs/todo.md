# Session 23 — Amrita NK Selection Fix (Complete)

**Branch:** `feature/amrita-ramakumar-formula`
**Status:** Code done, release build pending

---

## Completed this session

- [x] Read Ramakumar book text — confirmed X values correct, formula correct
- [x] Found Ramakumar 1h NK rule: if sunrise NK exits < 60 min → use next NK
- [x] Implemented fix in `muhurtha.dart` → `_amritKalamRamakumar()`
- [x] `dart analyze` — no errors
- [x] Re-ran `validate_ramakumar2.dart` — results stable (rare edge case)

---

## Blocked on (next session)

- [ ] `flutter build apk --release` — must pass before merge (Rule #8)
- [ ] Install on device, spot-check Jan 15 2024 and Oct 10 2028 (outside lookup range)
- [ ] Commit Session 23 changes
- [ ] Merge: `feature/amrita-ramakumar-formula` → `feature/ayanamsha-calibration` → `main`
- [ ] Push to remote

---

## Key validation results

```
Dec 2025–Mar 2026 (well-validated): ≤30min=40.2%, mean=121min
2026-27 table:                      ≤30min=21.9%, mean=116min
Apr–Nov 2025 (OCR issues):          ≤30min=13.9%, mean=159min
ALL:                                ≤30min=23.1%, mean=131min
```

Accuracy ceiling with Drik Moon: ~40% within 30 min. Lookup table covers 2025-2027.
