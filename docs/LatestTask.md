# Latest Task — Session 7 Complete

**Last updated:** Mar 2, 2026
**Branch:** `feature/alarm-sound-channel` (pending merge to main)
**APK:** 58.6 MB, installed ✓

---

## Session 7 — All Done ✓

- Alarm sound channel (`panchangam_alarms`) — `AudioAttributesUsage.alarm` + system alarm ringtone
- To-Do feature (Pro) — `UserTodo` model, `UserTodoProvider`, `TodoFormScreen`, Events|To-Dos tab bar, live targetDate preview
- Festival markers — confirmed in `day_cell.dart` (amber border + name)
- Bug fix: To-Do targetDate recomputes live on tithi/month change in edit mode

## Verification Checklist (Session 7)
- [x] Alarm mode sounds like a real alarm
- [x] To-Do: create → correct target date shown
- [x] To-Do: checkbox → Completed section
- [x] To-Do: swipe to delete
- [x] To-Do: edit + tithi change → Gregorian date updates live
- [x] Events tab unaffected
- [ ] "Sched." test notification fires after 1 min (not re-tested this session)
- [ ] Merge `feature/alarm-sound-channel` → main

---

## Next Session — Work Items

### New (Mar 2, 2026 — Srikar)
1. **Agents folder** — create `agents/` directory with hierarchical folder structure; write `.md` agent files relevant to the project (calculation agents, notification agents, data agents, etc.)
2. **Re-validate Grahanam timings** — eclipse start/peak/end times appear to be off; full re-check needed

### From Previous Claude Session (captured Mar 1, 2026 — still pending)
3. **"Mark this Tithi" paywall fix** — currently works without sign-in. Gate on `user != null` + `isPremium`; redirect to Pro screen if either fails.
4. **Pro screen feature excerpt** — add short readable list of Pro features so users understand what they get before subscribing.
5. **"Mark this Tithi" → two buttons** — split into Event (bookmark icon) + To-Do (checklist icon). Both behind paywall. To-Do opens `TodoFormScreen`.
6. **Splash screen — app logo** — show app logo asset above/below mantra text, same deep-blue bg.
7. **Sign-out → sign-in false error** — sign-in succeeds in state but shows "Sign in failed". Surface exact error from logcat, find root cause, fix.
8. **Disclaimer tile** — collapsible tile in Settings/About. Collapsed by default. Text: calculations may not be fully accurate for all regions/traditions; team actively improving.

### Housekeeping
- Delete remote branch `claude/review-project-context-pT0c8` — content already absorbed into LatestTask.md

### Deferred
- Paywall screen (RevenueCat / Google Play Billing)
- Firestore Pro subscription check (replace hardcoded email whitelist)
- Settings notification preferences
- Light/dark theme
- iOS support

---

## Rebuild + Reinstall APK

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
