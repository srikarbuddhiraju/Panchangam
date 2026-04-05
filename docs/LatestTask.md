# Latest Task — Session 29 Complete

**Last updated:** Apr 5, 2026
**Branch:** `main`

---

## STATUS: Security hardening done — Play Store blocked on $25 dev account

### Session 29 — What was done

1. ✅ Contact email updated to `panchangam@srikarbuddhiraju.com`
   - `docs/privacy-policy.md:63` and `docs/play-store/privacy-policy.md:59`
2. ✅ F3 security fix: moved `_proEmails` out of source
   - `auth_service.dart` now uses `String.fromEnvironment('PRO_EMAILS')`
   - Real emails in gitignored `build_release.sh` only
   - Template at `build_release.sh.example` (tracked)
   - Debug mode warns loudly if `PRO_EMAILS` is empty
3. ✅ Git history rewritten: tester emails → `[REDACTED]` in all `auth_service.dart` blobs
   - Force pushed `main` — history is clean on GitHub
   - `security-findings.md` F3 marked resolved
4. 🔄 Marketing discussion started — not completed (session ended)

---

## NEXT SESSION — START HERE

### Blocked (external)
- **Play Store**: Google Play Developer account ($25) — budget, Srikar's call on timing

### Ready to continue
- **Marketing discussion** — answer this first:
  > Who is the primary user? Elder daily user or younger person planning muhurtams?
  > Telugu diaspora (NRI) or primarily India-based?

### Build process (CHANGED — always use this)
```bash
./build_release.sh    # gitignored, has --dart-define=PRO_EMAILS
```
Never run `flutter build apk --release` directly — that builds with no Pro access.

### Srikar's pending tasks
- [ ] Google Play Developer account ($25) — when budget allows
- [ ] Feature graphic: 1024×500px (deep navy bg, centered icon, "Panchangam" in gold)
- [ ] Retake `ps-04-pro-tab.png` screenshot (current is empty state)

---

## Key file locations
- Release keystore: `app/android/app/release.jks` (gitignored, local only)
- Signing credentials: `app/android/key.properties` (gitignored, local only)
- Build script: `build_release.sh` (gitignored) — USE FOR ALL RELEASE BUILDS
- Build template: `build_release.sh.example` (tracked)
- Security findings: `docs/security-findings.md`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy (GitHub Pages): `docs/privacy-policy.md`
- Privacy policy (Play Store ref): `docs/play-store/privacy-policy.md`
- APK: 58.9 MB (release, signed)
