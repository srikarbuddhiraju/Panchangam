# Latest Task — Session 26 Complete

**Last updated:** Mar 14, 2026
**Branch:** `feature/playstore-prep` — pending merge review

---

## STATUS: All dev tasks done — pending Srikar merge confirmation

### Verification checklist
- [x] Dec 10 2025 amrita entry corrected: (11,56) → (7,51) in `amrita_lookup.dart`
- [x] Play Store listing draft written: `docs/play-store/listing.md`
- [x] Privacy policy draft written: `docs/play-store/privacy-policy.md`
- [x] Roadmap updated (Pro tab marked complete, Play Store ← IN PROGRESS)
- [x] 7 device screenshots captured locally (not committed — in `docs/screenshots/`)
- [x] Old screenshots (12 files, Feb 22 era) removed from git tracking
- [x] `docs/screenshots/` added to `.gitignore` (fixed malformed entry)
- [x] `dart analyze` clean, release APK verified on device (58.9 MB)

---

## What was done Session 26

1. ✅ Fixed Dec 10 2025 amrita lookup — traced OCR raw (`తే.అమృత 7:51`) vs formula table artifact
2. ✅ Created `docs/play-store/listing.md` — full Play Store copy ready to paste
3. ✅ Created `docs/play-store/privacy-policy.md` — ready to host on GitHub Pages
4. ✅ Updated `docs/roadmap.md` — Pro tab [x], Play Store listing ← IN PROGRESS
5. ✅ Captured 7 Play Store screenshots via ADB (stored locally, NOT in git):
   - `ps-01-calendar.png` — March 2026 calendar, Ugadi highlighted
   - `ps-02-today-fivelibs.png` — 5 limbs, Mar 14
   - `ps-03-today-kalams-amrit.png` — Kalams + Sringeri Amrit attribution
   - `ps-04-pro-tab.png` — Pro tab hero + cards + empty events state
   - `ps-05-today-ugadi-festival.png` — Today tab, Ugadi (Mar 19)
   - `ps-06-today-ugadi-kalams-amrit.png` — Kalams + Amrit for Ugadi
   - `ps-07-settings.png` — Settings with Pro badge + green notification checkmark
6. ✅ Removed 12 old screenshots from git tracking (`git rm --cached`)
7. ✅ Fixed malformed `.gitignore` (`Logos & Assetsdocs/screenshots/` → split correctly)

---

## NEXT SESSION — START HERE

### Goal: Merge → Play Store internal testing

1. Merge `feature/playstore-prep` → `main`
2. Push to GitHub + enable GitHub Pages for privacy policy
   - URL: `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
3. Build release APK (`flutter build apk --release`) for upload
4. Play Store Console: upload APK, add testers, submit listing
5. Amrita data quality (deferred, low priority):
   - Spot-check Dec 11, Dec 15, Dec 16 entries (suspected Shē.amṛta vs Dī.amṛta mismatch)
   - Spot-check 10–15 Apr–Nov 2025 non-standard entries (తే/శే.అమృత) against PDF

### Srikar's tasks (independent)
- [ ] Google Play Developer account ($25 one-time) if not done
- [ ] Feature graphic: 1024×500px (deep navy bg, centered icon, "Panchangam" in gold)
- [ ] Enable GitHub Pages on repo → publish from `/docs` folder
- [ ] Retake `ps-04-pro-tab.png` screenshot after adding some test events (current is empty state)

## Key file locations
- Amrita lookup: `app/lib/core/data/amrita_lookup.dart`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy: `docs/play-store/privacy-policy.md`
- Screenshots: `docs/screenshots/` (local only, gitignored)
