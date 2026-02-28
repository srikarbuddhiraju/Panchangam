# Latest Task — Panchangam Pro: Session 3 Complete

**Last updated:** Feb 28, 2026
**Status:** Session 3 (Event UI) complete. Committed `28e62aa` on `feature/pro-session3-event-ui`. All 32 tests pass. Ready for Session 4 (Notifications).

---

## What Was Done This Session

### Session 3 — Event UI (All Done ✅)

**Branch:** `feature/pro-session3-event-ui`
**Commit:** `28e62aa`

| File | What Changed |
|------|-------------|
| `features/premium/premium_guard.dart` | NEW — wraps Pro features; upgrade teaser when free |
| `features/events/my_events_screen.dart` | NEW — list + empty state + swipe-delete + toggle + edit FAB |
| `features/events/event_form_screen.dart` | NEW — add/edit form: name EN/TE, tithi picker, month picker, reminder placeholder |
| `features/events/widgets/personal_events_card.dart` | NEW — gold-bordered card for day detail screens |
| `features/events/user_event_calculator.dart` | Added `matchingEvents()` for PanchangamData context |
| `features/family/family_screen.dart` | Two-branch: Pro → `MyEventsScreen()` directly, Free → thin Scaffold + PremiumGuard |
| `features/today/today_screen.dart` | Added PersonalEventsCard when isPremium + events match |
| `features/panchangam/panchangam_screen.dart` | Added PersonalEventsCard + "Mark this tithi" FAB |
| `app/routes.dart` | Added `/events/new?tithi=N` + `/events/:id` push routes |
| `app/.gitignore` | Refined `premium/` rule — ignores specific paywall files, allows `premium_guard.dart` |

### Design decisions
- `FamilyScreen` two-branch approach avoids double-Scaffold: Pro → `MyEventsScreen` (owns Scaffold+AppBar+FAB), Free → thin Scaffold + PremiumGuard teaser
- `PremiumGuard` teaser shows "Subscribe — Coming Soon" button (disabled, wired in Session 5)
- "Mark this tithi" FAB only visible when `isPremium=true` AND Panchangam data loaded
- Reminder toggle stored but TODO'd for Session 4 — no crash if enabled
- `premium_guard.dart` is safe to track in git (no pricing info) — gitignore updated to allow it

---

## To Do For Next Session

### Session 4 — Notifications
**New branch:** `feature/pro-session4-notifications`

- [ ] Add `flutter_local_notifications` to `pubspec.yaml`
- [ ] Create `app/lib/services/notification_service.dart` — singleton wrapper: init, permission request, schedule, cancel
- [ ] Update `AndroidManifest.xml` — add `POST_NOTIFICATIONS` + `SCHEDULE_EXACT_ALARM` permissions
- [ ] Update `user_event_provider.dart` — call `NotificationService.schedule()` on add/update, `cancelAll()` on delete/disable
- [ ] Update `main.dart` — call `NotificationService.init()` + re-schedule all active events on app start
- [ ] Wire reminder picker in `EventFormScreen` (minutes before tithi — currently placeholder)
- [ ] **Verify:** Add event with near-future reminder → notification fires on device

---

## How to Rebuild + Reinstall APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
