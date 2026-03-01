# Latest Task — Session 4 Complete: Notifications Live

**Last updated:** Mar 1, 2026
**Status:** Session 4 done. APK built (54.0 MB) and installed. Session 5 (Login + Pro user list) is next.

---

## FIRST THING NEXT SESSION — Login + Pro User List (Session 5)

This requires Firebase setup steps that Srikar must do manually first.

### Step A — Firebase project setup (Srikar does this)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create (or open) the Panchangam project
3. Enable **Authentication → Google Sign-In**
4. Add your Android app (`com.example.panchangam`) if not already added
5. Get the **SHA-1 fingerprint** for Google Sign-In:
   ```bash
   cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
   /home/srikarbuddhiraju/development/flutter/bin/keytool -list -v \
     -keystore ~/.android/debug.keystore -alias androiddebugkey \
     -storepass android -keypass android | grep SHA1
   ```
   Add that SHA-1 to the Firebase Android app settings.
6. Download `google-services.json` → place at:
   `app/android/app/google-services.json`

### Step B — Claude implements (next session)
Once `google-services.json` is in place:
- Add packages: `firebase_core`, `firebase_auth`, `google_sign_in`, `cloud_firestore`
- Build Google Sign-In flow + login screen
- Pro user check: `srikarbuddhiraju@gmail.com` → auto-grant Pro (stored in Firestore)
- Replace Pro toggle in Settings with real auth-based check

---

## Pro Tab Tweaks — Queued for After Session 5

### 1. Reminder redesign
- **Remove**: "N minutes before" dropdown (meaningless without a reference time)
- **Replace with**: specific time picker + days-before selector
  - e.g., "8:00 AM, 1 day before" or "7:30 AM, on the day"
  - `UserTithiEvent` model: replace `reminderMinutes: int?` with `reminderTime: TimeOfDay?` + `reminderDaysBefore: int` (0 = same day, 1 = day before, etc.)
  - `NotificationService`: schedule at `tithi_date - reminderDaysBefore days` at `reminderTime`

### 2. Notes field on events
- Add optional free-text `notes` field to `UserTithiEvent`
- Show in `EventFormScreen` as a multiline text field
- In `MyEventsScreen` event cards: expandable section (like festival cards) showing notes when tapped
- `UserTithiEvent.toMap()` / `fromMap()` updated to persist notes

---

## What Was Done This Session (Mar 1, 2026)

### Quick fix
- Renamed "Family" tab → "Pro" (gold star icon)
- `app_strings.dart`: `S.family` → `S.pro` (English: "Pro", Telugu: "ప్రో")
- `main_scaffold.dart`: icon `Icons.people` → `Icons.star_rounded`

### Session 4 — Notifications (complete)

**7 files changed, 1 new file created**

#### New: `app/lib/services/notification_service.dart`
- Singleton — `NotificationService.instance`
- `init()`: initialises timezone (Asia/Kolkata, hardcoded — India-only app), inits FLN plugin, requests POST_NOTIFICATIONS permission on Android 13+
- `scheduleForEvent(event, occurrences, lat, lng)`: schedules up to 3 notifications, each firing `event.reminderMinutes` minutes before sunrise on the tithi day
- `cancelForEvent(eventId)`: cancels all 3 potential slots for that event
- Notification ID formula: `event.id.hashCode ^ (i * 31)` (stable across restarts)

#### `AndroidManifest.xml`
Added:
- Permissions: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`
- Receivers: `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`

#### `user_event_calculator.dart` — `nextOccurrences()`
- Scans forward up to 400 days from a given date
- Returns up to N calendar dates where the event's tithi (+ optional month) matches
- Skips adhika maasa days (consistent with festival logic)

#### `user_event_provider.dart`
- `add()`: schedules notifications after saving
- `update()`: cancels then reschedules
- `delete()`: cancels before removing

#### `main.dart`
- `NotificationService.instance.init()` called before `runApp()`
- `_rescheduleAllNotifications()`: reads Hive directly, reschedules all active events on every startup — keeps alarms alive after device reboots

#### `event_form_screen.dart`
- Replaced "Coming soon" placeholder with a real `DropdownButton<int?>`
- Options: No reminder / 30 min / 1 h / 2 h / 6 h / 12 h / 1 day (before sunrise)
- `_save()` now passes `reminderMinutes` to `add()` and `update()`
- Both English and Telugu labels

### APK
- Built: `✓ Built app-release.apk (54.0MB)`
- Installed via `adb install -r` → **Success**
- Branch: `feature/pro-session4-notifications`
- GitHub push: **PENDING** — Srikar needs to push manually

---

## How to Test Notifications

Since Pro is currently debug-toggle only:
1. Run `flutter run` (debug build) — toggle appears in Settings
2. Enable Pro toggle → go to Pro tab → Add Event
3. Set a tithi that occurs soon (check which tithi is 2–3 days away in the app)
4. Set reminder = 30 min
5. Notification will fire 30 min before sunrise on that day

Once login is done (Session 5), you can test on the release APK with your real account.

---

## How to Rebuild + Reinstall APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
