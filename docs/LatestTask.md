# Latest Task — Session 7 Complete

**Last updated:** Mar 1, 2026
**Branch:** `feature/alarm-sound-channel` (pending merge to main)
**Commits:** `d9d08e0` (feat: alarm channel + To-Do feature), `395b528` (fix: targetDate live recompute)
**APK:** 58.6 MB, installed ✓

---

## Session 7 — All Done ✓

### 1. Alarm sound channel ✓
- New `panchangam_alarms` channel: `AudioAttributesUsage.alarm` + `UriAndroidNotificationSound('content://settings/system/alarm_alert')` + `fullScreenIntent: true` + `Importance.max`
- `scheduleForEvent()` uses `_alarmDetails()` for alarm type, `_details()` for reminder
- `scheduleForTodo()` + `cancelForTodo()` added to `NotificationService`

### 2. To-Do feature ✓
- `user_todo.dart` — model with `targetDate`, `isCompleted`, `isActive`, optional reminder
- `user_todo_provider.dart` — CRUD + Hive (`userTodosBox`), single notification per todo
- `todo_form_screen.dart` — title + tithi + month + reminder + notes form; **live targetDate preview** (gold italic, updates on every tithi/month change via `_recomputePreview()`)
- `my_events_screen.dart` — Events | To-Dos tab bar (ConsumerStatefulWidget + TabController)
- `main.dart` — opens `userTodosBox` + `_rescheduleTodoNotifications()` on startup
- `routes.dart` — `/todos/new` + `/todos/:id` push routes
- `UserEventCalculator.nextOccurrenceDate()` — scans forward ≤400 days for tithi match

### 3. Festival markers ✓
- Already in `day_cell.dart` (amber border + festival name) — confirmed + ticked in `features.md`

### 4. Bug fix: To-Do targetDate in edit mode ✓
- Root cause: form showed stored `_original!.targetDate`; save didn't recompute even when tithi/month changed
- Fix: `_previewDate` state + `_recomputePreview()` called in `initState` (post-frame) + on each tithi/month `onChanged`; save passes recomputed date to `copyWith(targetDate: newTarget)`

---

## Verification Checklist (Session 7) — Confirmed by Srikar

- [x] Alarm mode sounds like a real alarm ✓
- [x] To-Do: create → correct target date shown ✓
- [x] To-Do: checkbox → Completed section ✓
- [x] To-Do: swipe to delete ✓
- [x] To-Do: edit + tithi change → Gregorian date updates live ✓
- [x] Events tab unaffected ✓
- [ ] "Sched." test notification fires after 1 min (not re-tested this session)
- [ ] Merge `feature/alarm-sound-channel` → main

---

## Session 7 Remaining → see [todo.md](todo.md)

---

## What Was Done (Sessions 5–6, Mar 1, 2026)

### Session 5 — Google Sign-In + Auth UX
- Google Sign-In (v7 API), optional — core app works without login
- `FamilyScreen` checks auth → isPremium
- `_SignInTile` + `_LoginSheet` in Settings; auto-closes on success
- Mantra splash hoisted to wrap entire `authAsync.when()` — shows first frame
- Fixed grey screen (AuthGate above MaterialApp) + red error screen (SplashOverlay missing Directionality)

### Session 6 — Reminders Redesign + Notes + Alarm Type
- `UserTithiEvent`: `reminderMinutes` → `reminderHour?` + `reminderMinute` + `reminderDaysBefore` + `reminderType`
- `UserTithiEvent`: added `notes: String?`
- `NotificationService`: fires at user-chosen time N days before tithi; `reminder`→`inexact`, `alarm`→`alarmClock`
- `EventFormScreen`: toggle → SegmentedButton + time picker + days dropdown + notes field
- `PersonalEventsCard` + `MyEventsScreen`: expandable notes (StatefulWidget / ConsumerStatefulWidget)
- APK: 57.9 MB ✓

---

## Notification Bugs Fixed (feature/notification-fixes-and-event-card-detail)

| Bug | Root Cause | Fix |
|-----|-----------|-----|
| Notifications never show | `requestNotificationsPermission()` before `runApp()` — no Activity | Moved to `addPostFrameCallback` |
| Die after reboot | `ScheduledNotificationBootReceiver` exported=false | Changed to `exported=true` |
| Alarm mode fails | `exact_alarms_not_permitted` silently swallowed | Check `canScheduleExactNotifications()` first |
| Samsung/MIUI kills reminders | Battery opt defers inexact AlarmManager | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` + MethodChannel |

**Also:** Quickboot intents in boot receiver; alarm permission dialog in EventFormScreen; reminder info line on event cards.

---

## Battery Opt + Diagnostics (feature/notification-diagnostics)

- `HiveKeys.batteryOptAsked` — battery opt dialog only shown on first launch
- Settings → Notifications tile: permission check on build; red banner if denied; green tile + "Test" button if granted
- Event form SnackBar: shows next fire time after save (skips past timestamps)

---

## R8 Fix — CONFIRMED WORKING (feature/notification-diagnostics-2)

**Error:** `PlatformException: Missing type parameter` — R8 v3+ strips Signature from GSON TypeToken anonymous subclasses in `loadScheduledNotifications()`

**Fix (`android/app/proguard-rules.pro`):**
```
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
```
**`android/app/build.gradle.kts`:** added `proguardFiles(...)` to release buildType.

**Also added:** `scheduleMinuteTestNotification()` in NotificationService + "Sched." test button in Settings.

Srikar confirmed: "It worked now." Scheduled notifications fire correctly. ✓

---

## To-Do Feature — Confirmed Design (Session 7)

### Data model
```dart
class UserTodo {
  final String id;              // UUID
  final String title;           // Required
  final String? notes;          // Optional
  final int tithi;              // 1–30
  final int? teluguMonth;       // null = any paksha | 1–12 = specific month
  final DateTime targetDate;    // Computed: next occurrence at creation time
  final bool isCompleted;       // User marks done
  final bool isActive;          // Soft delete
  final int? reminderHour;      // null = no reminder
  final int reminderMinute;
  final ReminderType reminderType;
}
```

### Key decisions
- **One-time only** — pinned to next occurrence of chosen tithi; once past or completed → archived
- **Tithi-based** (NOT Gregorian date) — same date basis as Personal Events
- **Paywall**: fold into `MyEventsScreen` as Events | To-Dos tab bar — reuses existing `PremiumGuard`

### Architecture
- `user_todo.dart` — model + toMap/fromMap/copyWith
- `user_todo_provider.dart` — CRUD + Hive (`userTodosBox`), single notification
- `TodoFormScreen` — reuses tithi picker + `_ReminderRow`; stores `targetDate` on save
- `MyEventsScreen` — add Events | To-Dos tab bar
- Day detail — show matching To-Dos (targetDate == that day) with checkbox

---

## Rebuild + Reinstall

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
