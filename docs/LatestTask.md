# Latest Task — Session 24 Complete

**Last updated:** Mar 13, 2026
**Branch:** `feature/amrita-ramakumar-formula`
**Branched from:** `feature/ayanamsha-calibration`

---

## NEXT SESSION — START HERE

### What was done this session
1. ✅ Investigated PyJHora amrit_kaalam — uses Gauri Choghadiya (North Indian tradition), not nakshatra-based. Dead end.
2. ✅ Implemented True Chitra Paksha ayanamsha (Lahiri + Meeus nutation). Impact: ±0.5 min on NK timing — negligible but astronomically correct.
3. ✅ Ran NK-label-filtered X calibration (Di.Amrita only, NK-match only). Finding: empirical X values are ~4-7 units lower than Ramakumar across ALL nakshtras — systematic ~5-6h bias. Even with calibrated X: mean error 166 min (worse than raw Ramakumar 379 min on same subset). Root cause confirmed: high day-to-day variance in amrita fraction (StdDev 0.5–3.4 X-units). No formula can achieve 5-10 min accuracy.
4. ✅ Decision: no formula fallback for Amrit Kalam. Lookup-only. Outside Mar 2025–Apr 2027, show null (honest gap, not wrong times).
5. ✅ Updated muhurtha.dart — removed formula fallback, added clear docstring explaining why.
6. ✅ Updated muhurtha_card.dart — source attribution ("Sringeri Panchangam") shown with times; "Data not available for this date" when outside range.
7. ✅ Updated calculation-methods.md — honest accuracy table, full explanation of why no formula.
8. ✅ Updated lessons.md — added amrit kalam formula ceiling rule.
9. ✅ Updated memory + LatestTask.md.

### What is accurate (for any year, any location)
- Sunrise, sunset, moonrise, moonset
- All five Panchangam limbs: Vara, Tithi, Nakshatra, Yoga, Karana (±1–2 min)
- Kalam timings: Rahu, Gulika, Yamaganda (±1–2 min)
- Muhurthas: Abhijit, Dur Muhurta (±1–2 min)
- Festival dates, Samvatsara, Telugu month
- Eclipse timings: contact times ±2–5 min

### What is NOT calculated (Sringeri data only)
- **Amrit Kalam**: Mar 2025–Apr 2027 exact. Outside → null. No formula.
- **Durmuhurtha**: Standard weekday table formula (not verified against Sringeri — but formula is well-established across all panchangam systems)

### Remaining blockers before merge

- [ ] `flutter build apk --release` — required (Rule #8)
- [ ] Device spot-check: amrit kalam shows correctly for today, shows "Data not available" for a date in 2024
- [ ] Verify dart analyze passes

### After merge
- Update `app/lib/core/data/amrita_lookup.dart` each year when new Sringeri edition is published
- OCR pipeline: `.claude/skills/ocr/` + `docs/data/amrita_2526.csv` / `amrita_2627.csv`
