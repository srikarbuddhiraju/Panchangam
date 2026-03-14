# Latest Task — Session 27 Complete

**Last updated:** Mar 14, 2026
**Branch:** `main`

---

## STATUS: All dev tasks done — ready to push

### Verification checklist
- [x] Release keystore generated (`app/android/app/release.jks`, gitignored)
- [x] `key.properties` wired (gitignored), `build.gradle.kts` updated to release signing
- [x] Release APK builds and installs successfully (58.9 MB)
- [x] SHA-1 fingerprint added to Firebase Console → Google Sign-In works in release
- [x] Sign-in from Pro tab returns immediately (no infinite spinner)
- [x] Stale `isPremium=true` bug fixed — clears on sign-out
- [x] Pro tab shows app logo (navy) in avatar when signed out
- [x] F1 marked resolved in `docs/security-findings.md`

---

## What was done Session 27

1. ✅ Added `siddhipranamya597@gmail.com` as Pro tester in `auth_service.dart`
2. ✅ Generated release keystore (`release.jks`, alias `panchangam`)
3. ✅ Wired `key.properties` + `build.gradle.kts` for release signing (F1 resolved)
4. ✅ Added release SHA-1 to Firebase Console → Google Sign-In works in release APK
5. ✅ Fixed `isPremium` stale value bug — now clears when signed out (`main.dart`)
6. ✅ Fixed Pro tab infinite spinner after sign-in (pass `onSuccess: nav.pop`)
7. ✅ Pro tab avatar now shows app logo when signed out (not `✦` symbol)
8. ✅ Navy container bg on avatar circle → no white clip edge on logo

---

## NEXT SESSION — START HERE

### Goal: Push + Play Store internal testing

1. Push to GitHub (`git push origin main`)
2. Enable GitHub Pages for privacy policy
   - URL: `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
3. Play Store Console: upload APK, add 5+ testers, submit listing
4. Tackle F3 (email whitelist in git) — move `_proEmails` out of source

### Srikar's tasks (independent)
- [ ] Google Play Developer account ($25 one-time) if not done
- [ ] Feature graphic: 1024×500px (deep navy bg, centered icon, "Panchangam" in gold)
- [ ] Enable GitHub Pages on repo → publish from `/docs` folder
- [ ] Retake `ps-04-pro-tab.png` screenshot after adding test events (current is empty state)

## Key file locations
- Release keystore: `app/android/app/release.jks` (gitignored, local only)
- Signing credentials: `app/android/key.properties` (gitignored, local only)
- Security findings: `docs/security-findings.md`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy: `docs/play-store/privacy-policy.md`
