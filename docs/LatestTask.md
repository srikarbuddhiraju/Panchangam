# Latest Task — Session 9 In Progress

**Last updated:** Mar 2, 2026
**Branch:** `feature/session9-pro-ui`

---

## Session 9 — Work Items

### Completed this session
- [x] "Mark this Tithi" paywall fix — FAB visible to all; tapping redirects: not signed-in → login sheet, not Pro → PremiumTeaser sheet, Pro → action picker
- [x] "Mark this Tithi" → two buttons — Event (bookmark) + To-Do (checklist), both wired to real routes (`/events/new` + `/todos/new`)
- [x] Pro screen feature excerpt — PremiumTeaser now shows 4 bullet-point feature list with check icons
- [x] Splash screen logo — icon.png (80×80, rounded) above mantras
- [x] Disclaimer tile — collapsible ExpansionTile in Settings (after Version), bilingual, acknowledges Sringeri as primary reference
- [x] Sign-in false error — surfaced with `debugPrint` + shows exception type in UI per HARD RULE #1

### Pending this session
- [ ] Build release APK + install on device
- [ ] Device test: FAB visible, paywall gate works, action picker opens
- [ ] Device test: splash shows logo
- [ ] Device test: disclaimer tile visible and collapsible in Settings
- [ ] Device test: sign in/out flow — record exception type from UI if error appears
- [ ] Commit + delete remote branch `claude/review-project-context-pT0c8`

---

## Housekeeping
- Delete remote branch `claude/review-project-project-pT0c8` — `git push origin --delete claude/review-project-context-pT0c8`
- Push `feature/session9-pro-ui` to origin when session complete

---

## Rebuild + Reinstall APK

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
