# Latest Task — Family Tab: Coming Soon Teaser + Pricing Cleanup

**Last updated:** Feb 28, 2026
**Status:** DONE. Committed (f908146). Ready to push.

---

## What Was Done This Session

### Family Tab Rewrite
- `family_screen.dart` → Coming Soon teaser screen
- 4 feature cards: Tithi Birthdays, Family Occasions, Smart Reminders, Cross-device Sync
- Bilingual (Telugu/English), Saffron/Gold theme, no pricing shown
- Removed PaywallScreen import entirely

### Pricing Files Hidden from Public Repo
- `paywall_screen.dart` and `premium_shell_screen.dart` untracked via `git rm --cached`
- Files still exist on disk locally (not deleted)
- Added to `app/.gitignore` under `# Pricing / paywall — not for public repo`

### Dependency Removed
- `in_app_purchase: ^3.2.0` removed from pubspec.yaml
- 4 packages cleaned out: in_app_purchase + 3 sub-packages

### Build Verified
- `flutter build apk --release` → ✓ 52.4MB (no errors)
- Device not connected at time of install — install manually before testing

---

## To Do For Next Session

- Install APK and verify Family tab shows teaser (no pricing visible)
- Push to origin/main: `git push origin main`
- Continue MVP checklist:
  - Remove autoDispose from festivalProvider + eclipseProvider
  - Sringeri disclaimer in app UI
  - Rohini Wed + Punarvasu Sat dual Amrit Kalam windows (architecture upgrade)
  - Play Store account setup (Srikar)

---

## How to Rebuild APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
