# Next Sessions — Pro Tab + April Release

**Target release:** First week of April 2026
**Current branch:** `main` (all amrita work merged)

---

## Session 25 — Pro Tab (next session)

**Branch:** `feature/pro-tab-redesign`

### Dev tasks (me)
- [ ] Create feature branch `feature/pro-tab-redesign`
- [ ] Rename "Family" tab → "Pro" tab (label, icon, route)
- [ ] Design and build premium-looking Pro tab UI:
  - Hero section: user avatar, name, Pro badge, subscription status
  - Feature cards: Events, To-Dos, Reminders, Alarms — each with icon + brief description
  - Sign-in prompt (for non-pro users) — polished paywall gate
  - Visual language: dark gradient, gold accents, modern card layout (premium feel)
- [ ] Remove/archive old `FamilyScreen` placeholder
- [ ] `dart analyze` → `flutter build apk --release` → install on device
- [ ] Commit + merge to main

### Design direction
- Think: Spotify premium tab, Apple One, Google One — dark/gradient hero + card grid
- Colors: deep navy background (#0B1437), gold (#C9A84C), subtle glassmorphism or frosted card effect
- Typography: bold hero text, subdued subtitle, badge chip for "Pro"
- Avoid: flat/plain list, basic white cards, anything that looks like settings

---

## Session 26 — Data Quality + Polish

- [ ] Fix Dec 10, 2025 amrit kalam entry (lookup=11:56, raw=~7:51)
- [ ] Spot-check 10-15 Apr-Nov 2025 entries against 2025-26 Sringeri PDF
- [ ] Fix any confirmed errors in `amrita_lookup.dart`
- [ ] UI polish pass: spacing, typography, edge cases
- [ ] Test edge cases: Amavasya, Adhika month, eclipse days, Ugadi 2026

---

## Release Prep (Srikar — independent, parallel)

- [ ] Play Store Developer account set up ($25 one-time)
- [ ] App name decision for store listing (≤30 chars)
- [ ] Store description: short (≤80 chars) + full (≤4000 chars) in English + Telugu
- [ ] Privacy policy (privacypolicygenerator.info or similar)
- [ ] Screenshots: 5–8, phone size, from actual device
- [ ] Internal testing track: upload APK, add 5+ testers
- [ ] Test on 2+ different Android devices/screen sizes

---

## Family Sharing — Deferred to v1.1 (May/June 2026)

**Decision (Mar 13, 2026):** Family sharing excluded from v1 release. Reasons:
- Full implementation (Firebase Firestore, invite flow, cross-device sync, roles) = 5-7 sessions
- 3-week runway to April 1st is too tight to build it well
- Better to ship Pro tab cleanly than rush family features

**What v1.1 family sharing will include:**
- Create/join a family group (Firebase)
- Invite by email
- Shared calendar: see family members' events + occasions
- Shared To-Dos, Reminders
- Up to 6 members on Family Plan (₹149/month or ₹1199/year)
- Admin vs member roles
