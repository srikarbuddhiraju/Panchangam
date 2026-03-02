# Latest Task — Session 8 Complete ✓

**Last updated:** Mar 2, 2026
**Branch:** `feature/grahanam-timing-fix` → merged to main ✓

---

## Session 8 — In Progress

### Completed this session
- [x] Merged `feature/alarm-sound-channel` → main (Session 7 work)
- [x] Created `.claude/skills/` with 8 project slash commands (session-start, session-end, build-release, build-debug, new-feature, verify-date, grahanam-check, notify-test)
- [x] `docs/agents/README.md` — index of all commands
- [x] **Eclipse timing fix** — `feature/grahanam-timing-fix` committed
  - Rewrote `eclipse.dart` with shadow geometry (shadow miss-distance vs old 9.5° node threshold)
  - Fixed `lunar_position.dart` latitude corrections to correct Meeus eq. 47.2
  - Sep 7 2025: duration 207 min (NASA 208 min ✓), dates correct, sutak correct
  - Mar 3 2026: duration 216 min (NASA 212 min ✓), dates correct

### Pending this session
- [x] Create `/accuracy-check`, `/code-review`, `/dep-check` skills
- [x] Build release APK + install on device
- [x] Device test: eclipse screen verified against Sringeri Panchangam
  - App: Sparsha 15:16, Moksha 18:53 IST (Mar 3 2026)
  - Sringeri: Sparsha 15:20, Moksha 18:47 IST — delta ±4–6 min ✓
- [x] Merge `feature/grahanam-timing-fix` → main ✓

---

## Next Session — Work Items

1. **"Mark this Tithi" paywall fix** — gate on `user != null` + `isPremium`; redirect to Pro screen if either fails
2. **Pro screen feature excerpt** — short readable list of Pro features before subscribing
3. **"Mark this Tithi" → two buttons** — split into Event (bookmark) + To-Do (checklist). Both paywall-gated.
4. **Splash screen — app logo** — show logo asset above/below mantra text, same deep-blue bg
5. **Sign-out → sign-in false error** — sign-in succeeds in state but shows "Sign in failed". Logcat → fix.
6. **Disclaimer tile** — collapsible tile in Settings/About, collapsed by default

### Housekeeping
- Delete remote branch `claude/review-project-context-pT0c8`
- Push main to origin (Srikar — SSH not configured on this machine)

---

## Rebuild + Reinstall APK

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
