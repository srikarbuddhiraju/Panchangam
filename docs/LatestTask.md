# Latest Task — Session 31 In Progress

**Last updated:** May 1, 2026
**Branch:** `main`

---

## STATUS: Play Store submission in progress

### Session 31 — What was done

1. ✅ Play Console account created (May 1, 2026) — all verifications done
2. ✅ AAB build: `build_release.sh` updated — default now builds AAB (Play Store), `--apk` flag for device testing
   - AAB at: `app/build/app/outputs/bundle/release/app-release.aab` (48.0 MB)
3. ✅ Screenshots taken (all 6, retaken with Pro tab):
   - `ps-01-calendar.png` — May 2026 calendar with festival highlights
   - `ps-02-today.png` — Five Limbs + Daily Timings
   - `ps-03-timings.png` — Muhurthas + Amrit Kalam + Calendar Context
   - `ps-04-pro-tab.png` — Paywall + Pro features + ₹99/month CTA
   - `ps-05-eclipse.png` — Aug 12 2026 Annular Solar Eclipse with Sutak
   - `ps-06-settings.png` — Language, City, Theme, Notifications
4. ✅ Feature graphic generated: `docs/screenshots/feature-graphic.png` (1024×500px)
   - Deep navy (#0B1437), centered icon, gold "Panchangam" title, no tagline

### Package name
`com.sbb.panchangam` (permanent — set in Play Console)

---

## NEXT SESSION — START HERE

### Play Console submission checklist
- [ ] Upload AAB (`app/build/app/outputs/bundle/release/app-release.aab`)
- [ ] Upload feature graphic (`docs/screenshots/feature-graphic.png`)
- [ ] Upload screenshots (all 6 from `docs/screenshots/`)
- [ ] Fill store listing (copy from `docs/play-store/listing.md`)
- [ ] Privacy policy URL: `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
- [ ] Content rating questionnaire (all None/No → Everyone)
- [ ] Submit for review

### After submission
- **DST handling** (v1.1): Add `timezone` package for proper DST support (deferred)
- **Security F2**: Client-side `isPremium` fix before billing goes live
- **Security F4**: GoRouter redirect guard for `/events/*` and `/todos/*`

### Build process
```bash
./build_release.sh        # AAB for Play Store
./build_release.sh --apk  # APK for device install/testing
```

---

## Key file locations
- Release keystore: `app/android/app/release.jks` (gitignored, local only)
- Signing credentials: `app/android/key.properties` (gitignored, local only)
- Build script: `build_release.sh` (gitignored) — USE FOR ALL RELEASE BUILDS
- Build template: `build_release.sh.example` (tracked)
- AAB (Play Store): `app/build/app/outputs/bundle/release/app-release.aab`
- Feature graphic: `docs/screenshots/feature-graphic.png`
- Screenshots: `docs/screenshots/ps-01` through `ps-06`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy: `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
