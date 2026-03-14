# Panchangam — Release Roadmap

## Release Target
**First week of April 2026** — Play Store, Android only.

---

## v1.0 — April 2026 (current focus)

### Must ship
- [x] All 5 Panchangam limbs (Tithi, Vara, Nakshatra, Yoga, Karana)
- [x] All daily timings (Sunrise/Sunset, Moonrise/Moonset, Kalams, Muhurthas)
- [x] Amrit Kalam — Sringeri lookup table (Mar 2025–Apr 2027), honest gap disclosure
- [x] Calendar grid with Tithi/Nakshatra per cell
- [x] Day detail view (full Panchangam per day)
- [x] Festivals (major Telugu Hindu festivals)
- [x] Location picker (city-based, persisted)
- [x] Telugu + English language toggle
- [x] App icon (deep navy + sun/moon)
- [x] Pro features: To-Dos, Reminders, Alarms, Events (tithi-based)
- [x] Google Sign-In + Firebase Auth, Pro gate
- [x] Eclipse timings (lunar + solar, contact times)
- [ ] Pro tab — replaces Family tab — premium UI (sleek/modern/dark gradient + gold)
- [ ] Play Store listing (title, description, screenshots, privacy policy)
- [ ] Internal testing pass (5+ users, varied devices)

### Family tab decision
**Family sharing excluded from v1.** Pro tab replaces Family tab.
Family sharing ships as v1.1 (target May/June 2026) — see below.

---

## v1.1 — May/June 2026

### Family Sharing (Pro feature, Family Plan tier)
- [ ] Create or join a family group (Firebase Firestore)
- [ ] Invite by email
- [ ] Shared calendar: family members' events + occasions visible
- [ ] Shared To-Dos + Reminders
- [ ] Up to 6 members on Family Plan (₹149/month or ₹1199/year)
- [ ] Admin vs member roles
- [ ] Amrit kalam data update: OCR Sringeri 2027-28 edition when released

### Polish & fixes
- [ ] Fix Dec 10, 2025 amrit kalam OCR error + spot-check Apr-Nov 2025 entries
- [ ] Sutak timings for eclipses
- [ ] Dark mode / theme toggle
- [ ] Tithi-based birthday UX (dedicated label, not just generic event)
- [ ] Death anniversary UX

---

## v2.0 — Q3/Q4 2026

- [ ] iOS release + Apple Sign-In
- [ ] Muhurtham finder
- [ ] Home screen widget
- [ ] PDF export of monthly Panchangam
- [ ] Jatakam basics (birth chart basics)
- [ ] Web app

---

## Known Data Quality Items

| Issue | Priority | Status |
|---|---|---|
| Dec 10, 2025 amrit kalam: lookup=11:56, raw=~7:51 | Medium | Needs manual fix |
| ~10-15 Apr-Nov 2025 non-standard (తే/శే.అమృత) entries unverified | Low | Spot-check next session |
| 52 "Unknown" nakshatra entries in CSVs (time may still be correct) | Low | Monitor |

---

## Things Srikar Can Do Without Claude

### App Store / Release Prep
- [ ] Google Play Developer account ($25 one-time) if not done
- [x] App name: **Panchangam** — final (Mar 13, 2026). Pan-India scalable, no regional qualifier.
- [ ] Store listing: short desc (≤80 chars) + full desc (≤4000 chars) in English + Telugu
- [ ] Privacy policy (privacypolicygenerator.info or similar)
- [ ] Screenshots: 5–8 screenshots from device, phone size
- [ ] Internal test track: upload APK, add 5+ testers on Play Console

### Testing
- [ ] Verify 10+ dates against DrikPanchang (tithi, nakshatra, kalams, muhurthas)
- [ ] Test on 2+ different Android devices/screen sizes
- [ ] Test edge cases: Amavasya, Purnima, Adhika month (May 2026), eclipse days
- [ ] Test location change, language toggle, time format toggle
