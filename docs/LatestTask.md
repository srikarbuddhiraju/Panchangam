# Latest Task — Panchangam Pro: Sessions 1–3 Merged, APK Installed

**Last updated:** Feb 28, 2026
**Status:** Sessions 1–3 merged to main. Bug fixed. APK built (52.9MB) and installed on device. Ready for Session 4.

---

## Quick Fixes — Do Before Session 4

### 1. Rename "Family" tab → "Pro"
**Files to change:**
- `app/lib/shared/widgets/main_scaffold.dart` — bottom nav label `'Family'` → `'Pro'`
- `app/lib/core/utils/app_strings.dart` — Telugu label for Family tab (if exists)

### 2. Debug toggle not visible in Settings
`kDebugMode` is `true` only in debug builds (`flutter run`), NOT in release APKs.
The toggle is hidden in the installed release APK — this is correct behaviour by design.
**To test Pro features on device:** either:
- Option A: Use `flutter run` (debug build) — toggle will appear in Settings
- Option B: Change the guard from `kDebugMode` to a compile-time flag or always-show in dev
- **Decision needed from Srikar**: keep it debug-only, or add a hidden tap gesture (e.g., tap version number 5× to unlock) for release testing?

---

## FIRST THING NEXT SESSION — Start Session 4 (Notifications)

Sessions 1–3 are merged to main. APK is on the device. Begin Session 4:

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam
git checkout main && git pull   # if needed after Srikar pushes manually
git checkout -b feature/pro-session4-notifications
cd app && flutter pub add flutter_local_notifications
```

Also: Srikar needs to manually push to GitHub (SSH auth needed):
```bash
git push origin main
```

---

## What Was Done This Session

### Branches merged to main (fast-forward, no conflicts)
- `feature/pro-session1-data-foundation` → main ✅
- `feature/pro-session2-calendar-integration` → main ✅
- `feature/pro-session3-event-ui` → main ✅

### Bug fixed during build
**Missing `import 'user_tithi_event.dart'`** in three files:
- `features/calendar/calendar_provider.dart`
- `features/today/today_screen.dart`
- `features/panchangam/panchangam_screen.dart`

`dart analyze` (MCP tool) reported no errors — the compiler caught it during `flutter build apk --release`. Fixed and committed (`faa31a0`). Lesson added to `docs/lessons.md`.

### APK built and installed
- Build: `✓ Built app-release.apk (52.9MB)`
- Installed: `adb install -r` → Success on device `10BDAH07CM000MQ`
- GitHub push: **PENDING** — auth token expired. Srikar needs to push manually.

### Main branch log (top commits)
```
efe15d5  docs: add build lesson
faa31a0  fix: add missing UserTithiEvent import (3 files)
c3fbf92  docs: full Session 4 handoff
29cc78c  docs: add lessons + Q&A from Pro Sessions 1–3
6cead70  docs: update LatestTask — Session 3 complete, Session 4 ready
28e62aa  feat(pro-session3): Event UI — MyEventsScreen, EventFormScreen, PremiumGuard, routes
7e52895  feat(pro-s2): Session 2 — calendar integration for personal events
77f1603  feat(pro-s1): Session 1 — data foundation for Panchangam Pro
```

---

## Session 4 — Notifications (TODO)

**Branch to create:** `feature/pro-session4-notifications`

### Step-by-step plan

**Step 1 — Add package**
```bash
cd app && flutter pub add flutter_local_notifications
```

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
- `cancelForEvent(String eventId)` — cancels all notifications for that event
- Notification ID formula: `eventId.hashCode ^ (occurrenceIndex * 31)`

**Step 4 — Add nextOccurrences to UserEventCalculator**
File: `app/lib/features/events/user_event_calculator.dart`
Add: `static List<DateTime> nextOccurrences(UserTithiEvent event, DateTime from, {int count = 3})`

**Step 5 — Wire UserEventProvider**
File: `app/lib/features/events/user_event_provider.dart`
- `add()` / `update()`: schedule after saving
- `toggleActive()`: cancel if disabling, reschedule if enabling
- `delete()`: cancel before removing

**Step 6 — Wire main.dart**
- `await NotificationService.instance.init()`
- Re-schedule all active events with reminders on app start

**Step 7 — Wire EventFormScreen reminder picker**
File: `app/lib/features/events/event_form_screen.dart`
- Replace placeholder with real `DropdownButtonFormField<int?>`
- Options: null (No reminder), 30, 60, 120, 360, 720, 1440 minutes

**Step 8 — Verify on device**
- Enable isPremium via debug toggle
- Add event with reminder = 30 min, tithi = near future
- Confirm notification fires

---

## How to Rebuild + Reinstall APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
