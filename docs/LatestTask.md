# Latest Task — Session 31 Complete

**Last updated:** May 1, 2026
**Branch:** `main`

---

## STATUS: Closed testing submitted — awaiting Google review

### Session 31 — What was done

1. ✅ Play Console account created + all verifications done (May 1, 2026)
2. ✅ `build_release.sh` updated — default builds AAB, `--apk` for device testing
3. ✅ All 10 screenshots taken and uploaded to Play Console
   - Phone (6): calendar, today, timings, pro tab, eclipse, settings
   - 7" tablet (2): 600×1024 — calendar, today
   - 10" tablet (2): 1080×1920 (9:16) — calendar, today
4. ✅ Feature graphic: `docs/screenshots/feature-graphic.png` (1024×500px, navy + gold)
5. ✅ Tablet layout fixed: calendar fills full width + aspect-ratio cell height cap
6. ✅ Security F2: `isPremiumProvider` derived from Firebase auth stream — Hive removed
7. ✅ Security F4: GoRouter redirect blocks `/events/*`, `/todos/*`, `/my-events` for signed-out users
8. ✅ Delete account page: `https://srikarbuddhiraju.github.io/Panchangam/delete-account`
9. ✅ Docs/logo: `docs/logo/icon-solid.png` + `icon-transparent.png`
10. ✅ AAB submitted to Play Console closed testing — version 1.0.0+2

### Package name
`com.sbb.panchangam` (permanent — set in Play Console)

---

## NEXT SESSION — START HERE

### Play Console status
- ✅ AAB v1.0.0+2 submitted to closed testing — **awaiting Google review**
- Once approved: share tester invite link from Play Console
- Need **12 testers opted-in for 14 days** → then apply for production

### To do next session
1. **Recruit 12 testers** — post invite link once Google approves (family/WhatsApp groups)
2. **After 14 days** → apply for production in Play Console
3. **IAP billing** — ₹149 one-time lifetime, regional pricing via Play Console per country
4. **DST handling** (v1.1) — `timezone` package for proper DST (deferred)

### Security — all done
- ✅ F1: Debug keystore (Session 27)
- ✅ F2: isPremiumProvider from auth stream — Hive removed (Session 31)
- ✅ F3: Email whitelist out of git (Session 29)
- ✅ F4: GoRouter route guards (Session 31)
- Remaining: IAP server-side verification — implement with billing

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
