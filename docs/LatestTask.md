# Latest Task — Panchangam Pro: Ready for Session 4

**Last updated:** Feb 28, 2026
**Status:** Sessions 1–3 complete. All committed on respective branches. Session 4 (Notifications) is next.

---

## FIRST THING NEXT SESSION — Merge branches to main

Sessions 1–3 are all verified (32 tests pass, no analyzer errors) but NOT yet merged to main.
**Do this before creating the Session 4 branch:**

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam
git checkout main
git merge feature/pro-session1-data-foundation
git merge feature/pro-session2-calendar-integration
git merge feature/pro-session3-event-ui
git push origin main
git checkout -b feature/pro-session4-notifications
```

---

## Session 4 — Notifications (TODO)

**Branch to create:** `feature/pro-session4-notifications`
**Goal:** When a user saves a personal tithi event with a reminder, a notification fires N minutes before that tithi date. Works even after app restarts.

### Step-by-step plan

**Step 1 — Add package**
```bash
cd app
flutter pub add flutter_local_notifications
```
Verify: no conflicts with existing packages.

**Step 2 — AndroidManifest.xml**
File: `app/android/app/src/main/AndroidManifest.xml`
Add inside `<manifest>` (before `<application>`):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```
Also add inside `<application>`:
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

**Step 3 — Create NotificationService**
File: `app/lib/services/notification_service.dart`
- Singleton class
- `init()` — initialize plugin, request permission (Android 13+)
- `scheduleForEvent(UserTithiEvent event, List<DateTime> occurrences)` — schedules one notification per occurrence (up to 3), N minutes before the datetime
- `cancelForEvent(String eventId)` — cancels all notifications for that event (by eventId-based ID)
- Notification ID formula: `eventId.hashCode ^ (occurrenceIndex * 31)` (avoids collisions)

**Step 4 — Wire UserEventCalculator: next occurrences**
File: `app/lib/features/events/user_event_calculator.dart`
Add: `static List<DateTime> nextOccurrences(UserTithiEvent event, DateTime from, {int count = 3})`
- Uses existing tithi-match logic
- Returns next N dates (as DateTime at midnight) when this event's tithi falls
- Needs PanchangamEngine to compute tithi for candidate dates
- Note: this is the complex part — may need to iterate day-by-day or use an estimate approach

**Step 5 — Wire UserEventProvider**
File: `app/lib/features/events/user_event_provider.dart`
- In `add()` and `update()`: after saving to Hive, call `NotificationService.scheduleForEvent(event, nextOccurrences(event, DateTime.now()))`
- In `toggleActive()`: if disabling → `cancelForEvent(event.id)`. If enabling → reschedule.
- In `delete()`: call `cancelForEvent(event.id)` before removing from Hive
- All calls wrapped in `if (event.reminderMinutes != null)`

**Step 6 — Wire main.dart**
File: `app/lib/main.dart`
- After Hive opens: call `await NotificationService.instance.init()`
- Then: for each active event with reminder, call scheduleForEvent with next occurrences
- This handles restarts and notification expiry

**Step 7 — Wire EventFormScreen reminder picker**
File: `app/lib/features/events/event_form_screen.dart`
- Replace the reminder placeholder with a real `DropdownButtonFormField<int?>`
- Options: null (No reminder), 30, 60, 120, 360, 720, 1440 minutes (labels: "30 min before", "1 hr", "2 hr", "6 hr", "12 hr", "1 day")
- Value stored in `_reminderMinutes` state variable, passed to event on save

**Step 8 — Verify on device**
- Enable isPremium via debug toggle in Settings
- Add event with tithi = today's tithi + reminder = 30 min
- Wait / set device clock forward → notification should fire
- Delete event → confirm notification is cancelled

---

## Sessions Completed

### Session 1 — Data Foundation ✅
**Branch:** `feature/pro-session1-data-foundation` | **Commit:** `77f1603`
- `app/assets/data/festivals.json` — 31 festivals migrated from Dart to JSON
- `app/lib/features/festivals/festival_loader.dart` — parse JSON at startup
- `app/lib/features/festivals/_archive/festival_data.dart.bak` — safety archive
- `app/lib/features/events/user_tithi_event.dart` — model (UUID, toMap/fromMap, copyWith)
- `app/lib/features/events/user_event_provider.dart` — Riverpod CRUD + Hive JSON persistence
- `app/lib/core/utils/hive_keys.dart` — added `userEventsBox`, `isPremium`
- `app/lib/main.dart` — opens `userEventsBox`, calls `FestivalLoader.initialize`
- `app/pubspec.yaml` — added `festivals.json` asset + `uuid: ^4.5.1`

### Session 2 — Calendar Integration ✅
**Branch:** `feature/pro-session2-calendar-integration` | **Commit:** `7e52895`
- `app/lib/features/events/user_event_calculator.dart` — `namesForDay()` tithi match
- `app/lib/core/calculations/panchangam_engine.dart` — DayData +4 fields: `teluguMonthNumber`, `isAdhikaMaasa`, `hasPersonalEvent`, `personalEventNames`
- `app/lib/features/calendar/calendar_provider.dart` — overlays user events (gated by isPremium)
- `app/lib/features/calendar/widgets/day_cell.dart` — gold italic personal event label
- `app/lib/features/settings/settings_provider.dart` — `isPremium` + `setIsPremium()`
- `app/lib/features/settings/settings_screen.dart` — kDebugMode toggle for isPremium

### Session 3 — Event UI ✅
**Branch:** `feature/pro-session3-event-ui` | **Commits:** `28e62aa`, `6cead70`, `29cc78c`
- `app/lib/features/premium/premium_guard.dart` — NEW: shows child or upgrade teaser
- `app/lib/features/events/my_events_screen.dart` — NEW: full list + swipe-delete + toggle + edit
- `app/lib/features/events/event_form_screen.dart` — NEW: add/edit form (reminder is placeholder)
- `app/lib/features/events/widgets/personal_events_card.dart` — NEW: gold card for detail screens
- `app/lib/features/family/family_screen.dart` — two-branch (Pro→MyEventsScreen, Free→PremiumGuard)
- `app/lib/features/today/today_screen.dart` — PersonalEventsCard shown when premium + matching
- `app/lib/features/panchangam/panchangam_screen.dart` — PersonalEventsCard + "Mark this tithi" FAB
- `app/lib/features/events/user_event_calculator.dart` — added `matchingEvents()`
- `app/lib/app/routes.dart` — `/events/new?tithi=N` + `/events/:id`
- `app/.gitignore` — refined: ignores specific paywall files, allows `premium_guard.dart`

---

## Merge Plan (confirmed with Srikar Feb 28 2026)

Merge each session branch to main after it is verified. Do NOT batch all at the end.
Sequence: Session 1 → Session 2 → Session 3 → main (fast-forward merges).
Then create next session branch off the updated main.

---

## How to Rebuild + Reinstall APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
