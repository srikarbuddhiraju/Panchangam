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

## Security Findings — tracked in [docs/security-findings.md](security-findings.md)

| ID | Severity | Status | Blocker for |
|----|----------|--------|-------------|
| F1 | 🔴 HIGH | ✅ Fixed (Session 27) | Play Store submission (debug keystore) |
| F2 | 🔴 HIGH | ❌ Open | Billing / v1.1 (client-side isPremium) |
| F3 | 🟡 MEDIUM | ❌ Open | Expanding tester list (email whitelist in git) |
| F4 | 🟡 MEDIUM | ❌ Open | Billing / v1.1 (no route guards) |

**F1 fixed** — release keystore wired. F3 still open (email whitelist in git).

---

## Pre-Launch Security — Secrets Manager (post-launch, before CI/CD)

- [ ] **Migrate keystore credentials to a secrets manager** — currently in `key.properties`
  (gitignored, local only). Before setting up any automated CI/CD pipeline (GitHub Actions,
  Fastlane, etc.), move credentials to a proper secrets store:
  - Option A: **GitHub Actions Secrets** — store `KEYSTORE_PASSWORD`, `KEY_ALIAS`,
    `KEY_PASSWORD`, and base64-encoded `release.jks` as repo secrets. Inject at build time.
  - Option B: **Google Cloud Secret Manager** — if a Cloud-based build pipeline is used.
  - **Do NOT hardcode credentials in any workflow YAML file.**
  - **Must complete before any automated push to Play Store is set up.**

---

## Polish — Icons

- [ ] **Replace Masa Shivaratri and Sankatahara Chaturthi icons** — current emoji (🔱, 🐘)
  display but are not appropriate. Srikar to create custom icons and hand off.
  Claude to swap them into `festival_data.dart`.

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
