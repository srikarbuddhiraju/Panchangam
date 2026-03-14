# Next Sessions — April Release

**Target release:** First week of April 2026
**Current branch:** `main` (merged)

---

## Session 26 — Data Quality + Play Store Prep ✅ DONE

- [x] Fix Dec 10, 2025 amrit kalam entry (11:56 → 7:51)
- [x] Play Store listing draft (`docs/play-store/listing.md`)
- [x] Privacy policy draft (`docs/play-store/privacy-policy.md`)
- [x] Device screenshots captured (7 screens, stored locally)
- [x] Old screenshots removed from git tracking

---

## Pre-Launch Security — Before Automated Play Store Updates

- [ ] **Move Pro email list out of source code** — `_proEmails` in `auth_service.dart` is
  tracked in git (public repo). Anyone can see which emails bypass the paywall.
  Fix: move Pro status to Firestore (`proUsers` collection keyed by email).
  The APK queries Firestore on sign-in instead of checking a hardcoded list.
  **Must fix before billing is wired or automated CI/CD push is set up.**

- [ ] **Verify Masa Shivaratri (🔱) and Sankatahara Chaturthi (🐘) icons display correctly**
  in the app. Icons are defined in `festival_data.dart` — confirm they render in
  the calendar grid and day detail cards on device.

---

## Session 27 — Play Store Submit (next)

- [ ] Merge `feature/playstore-prep` → `main`
- [ ] Push to GitHub + enable GitHub Pages for privacy policy
- [ ] Build release APK for Play Console upload
- [ ] Upload APK to Play Console internal test track
- [ ] Add 5+ internal testers

---

## Amrita Data Quality (low priority, can defer post-launch)

- [ ] Spot-check Dec 11, Dec 15, Dec 16 entries vs PDF (suspected She.amrita mismatch)
- [ ] Spot-check 10–15 Apr–Nov 2025 non-standard (తే/శే.అమృత) entries

---

## Release Prep — Srikar's Tasks

- [ ] Google Play Developer account ($25 one-time)
- [ ] Feature graphic: 1024×500px (navy bg, centered icon, gold text)
- [ ] Enable GitHub Pages → privacy policy at public URL
- [ ] Retake ps-04-pro-tab.png with test events added (current is empty state)
- [ ] Internal test track: upload APK, add 5+ testers on Play Console
- [ ] Test on 2+ different Android devices/screen sizes

---

## Family Sharing — Deferred to v1.1 (May/June 2026)

**Decision (Mar 13, 2026):** Family sharing excluded from v1.
- Full implementation = 5–7 sessions, too tight for April deadline
- Pro tab ships cleanly; family sharing ships as v1.1
- v1.1 scope: family group, invite by email, shared calendar/todos, 6 members, ₹149/mo
