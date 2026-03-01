# Latest Task — Session 6 Complete: Reminders Redesign + Notes + Alarm Type

**Last updated:** Mar 1, 2026
**Branch merged:** `feature/event-reminders-and-notes` → `main`
**APK:** 57.9 MB, built and installed via adb

---

## What Was Done This Session (Mar 1, 2026)

### Session 5 — Google Sign-In + Auth UX (complete, merged earlier)
- Google Sign-In via `GoogleSignInPlatform.instance` (v7 API)
- Sign-in is OPTIONAL — unauthenticated users see full app
- `FamilyScreen`: checks auth first, then isPremium
- Settings: `_SignInTile` + `_LoginSheet` bottom sheet with `onSuccess` auto-close
- Fixed grey screen on launch (AuthGate above MaterialApp)
- Fixed red error screen (SplashOverlay Stack missing Directionality)
- Mantra splash hoisted to wrap entire `authAsync.when()` — shows at first frame
- LoginScreen uses app icon asset; language-aware title; `onSuccess: VoidCallback?`

### Session 6 — Reminders Redesign + Notes + Alarm Type (complete, merged)

**7 files changed**

#### `user_tithi_event.dart`
- Added `ReminderType` enum: `{ reminder, alarm }`
- Replaced `reminderMinutes: int?` with: `reminderHour: int?`, `reminderMinute: int`, `reminderDaysBefore: int`, `reminderType: ReminderType`
- Added `notes: String?`
- Backwards-compatible: old events load with `reminderHour: null` (no reminder)

#### `notification_service.dart`
- Fires at `reminderHour:reminderMinute` on day that is `reminderDaysBefore` before tithi
- `ReminderType.reminder` → `AndroidScheduleMode.inexact`
- `ReminderType.alarm` → `AndroidScheduleMode.alarmClock` (exact)
- `_title()`: `Telugu · English` or just English
- `_body()`: `నేడు/రేపు/In N days` + notes snippet (≤80 chars)

#### `event_form_screen.dart`
- Toggle switch to enable/disable reminder
- When enabled: `SegmentedButton<ReminderType>` (bell=Reminder / alarm=Alarm)
- Time picker button + days-before dropdown (0/1/2/3/7)
- Notes `TextFormField` (3 lines, optional)
- `_save()` passes all new fields to `add()` and `update()`

#### `personal_events_card.dart`
- `_EventEntry` changed to `StatefulWidget` with expand/collapse for notes
- Chevron shown only when notes are non-empty; gold-tinted expandable container

#### `my_events_screen.dart`
- `_EventTile` changed to `ConsumerStatefulWidget` with expand/collapse for notes
- Sign-in prompt shown when `user == null` (app icon, deep blue bg)

---

## How to Rebuild + Reinstall APK

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```

---

---

## What Was Also Done This Session (Mar 1, 2026 — continued)

### Notification bug fixes (feature/notification-fixes-and-event-card-detail)

**Root causes found and fixed:**

| Bug | Root Cause | Fix |
|-----|-----------|-----|
| Notifications never show | `requestNotificationsPermission()` called before `runApp()` — no Activity → permission dialog never shown | Moved to `addPostFrameCallback` after `runApp()` |
| Notifications die after reboot | `ScheduledNotificationBootReceiver` was `exported=false` — Android 12+ drops system broadcasts to non-exported receivers | Changed to `exported=true` |
| Alarm mode always fails | `alarmClock` mode throws `exact_alarms_not_permitted`; exception silently swallowed | Check `canScheduleExactNotifications()` first; fall back to `inexact` + show dialog |
| Samsung/MIUI kills reminders | Battery optimization defers/kills inexact `AlarmManager.set()` | Added `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` + MethodChannel in `MainActivity.kt` |

**Also added:**
- Quickboot intents in boot receiver (`QUICKBOOT_POWERON`, HTC variant)
- Alarm permission dialog in `EventFormScreen` when alarm mode selected but permission absent
- Reminder/alarm info line in both event cards (Pro tab + Day tab): `🔔 8:00 AM · same day` / `⏰ 8:00 AM · 1 day before`
- Edit button in Day tab PersonalEventsCard: size 16 → 20 + 6px padding all sides (easy to tap)

---

---

## What Was Also Done This Session (Mar 1, 2026 — continued, 3rd pass)

### Battery opt dialog + notification diagnostics (feature/notification-diagnostics)

**Battery optimization dialog every launch — fixed:**
- Added `HiveKeys.batteryOptAsked` — stored in settingsBox after first prompt
- `requestPermissions(askBatteryOpt: bool)` — only prompts when `askBatteryOpt` is true
- `main.dart` reads the flag, passes false on subsequent launches → dialog never repeats

**Notification diagnostics added:**
- **Settings → Notifications tile**: checks `areNotificationsEnabled()` on build
  - If denied: red warning banner with instructions ("Settings → Apps → Panchangam → Notifications")
  - If granted: green tile + "Test" button that fires `showTestNotification()` immediately
  - Test button = definitive way to verify the channel + permission work
- **Event form SnackBar after save**: computes next occurrence and shows "Reminder set for 15/3/2026 at 8:00 AM" (4 seconds)
  - If tithi has no occurrence in 400 days: red SnackBar "No occurrence found — check tithi selection"
  - This tells the user WHEN to expect the notification, surfacing wrong tithi selection

---

---

## What Was Also Done This Session (Mar 1, 2026 — continued, current)

### Notification diagnostics — feature/notification-diagnostics-2

**Current confirmed state:**
- `show()` (immediate notification) works ✓ — channel, permissions, plugin all correct
- `zonedSchedule()` (scheduled notification) is **throwing an exception** ✗
  - Confirmed: tapping the new "Sched." test button surfaces a red error SnackBar
  - The exact error text was not yet captured — needed to read logcat or see full SnackBar text
- `catch (_)` in `_scheduleNotifications` (user_event_provider.dart) was silently swallowing all errors

**Changes in this branch (58.1 MB APK):**
1. **`notification_service.dart`** — added `scheduleMinuteTestNotification()`: calls `zonedSchedule()` for 1 min from now with `inexact` mode. Tests scheduling independently of tithi math.
2. **`settings_screen.dart`** — added "Sched." button next to "Test" in Notifications tile. Error is now surfaced in red SnackBar (`'Scheduling failed: $e'`) instead of silently failing.
3. **`event_form_screen.dart`** — fixed `_showReminderScheduledSnackBar()`: now skips past `notifyAt` timestamps and shows the **first genuinely future** fire time.
4. **`android/app/proguard-rules.pro`** (new) — R8 keep rules for `com.dexterous.flutterlocalnotifications.**` + GSON TypeToken rules.
5. **`android/app/build.gradle.kts`** — added `proguardFiles(...)` to release buildType.

**Error confirmed from screenshot:**
`PlatformException: Missing type parameter at com.google.gson.reflect.a.getSuperclassTypeParameter` — R8 v3+ strips Signature from TypeToken anonymous subclass in `loadScheduledNotifications()`.

**Root cause**: `-keepattributes Signature` alone is NOT enough for R8 v3+. Two specific rules required (GSON 2.9.1 official docs):
```
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
```

**Fix attempt 2 CONFIRMED WORKING by Srikar.** Scheduled notifications now fire correctly.

**Branch `feature/notification-diagnostics-2` ready to merge.**

---

## NEXT SESSION — What to Work On

### Session 7 — Priorities

**1. Alarm sound (carry-over — quick fix)**
`ReminderType.alarm` currently sounds identical to a reminder notification. Fix: add a `panchangam_alarms` notification channel with `AudioAttributesUsage.alarm` + system alarm ringtone URI. Use it for alarm mode only.

**2. To-Do feature (Pro) — Session 7 main focus**
See To-Do plan below. Users can add To-Dos for a specific Gregorian date with an optional reminder.

**3. Festival markers on calendar grid**
Gold dot or indicator on days with pre-loaded festivals.

**4. Firestore Pro subscription check**
Replace hardcoded email whitelist with real Firestore document query.

---

## To-Do Feature Plan (Session 7)

### What it is
Pro users can create To-Do items tied to a **tithi** (same as Events). Each To-Do has a title, optional notes, and an optional reminder. The key difference from Events: To-Dos have a **completion checkbox** — once done, mark it complete. Exact model and recurrence behaviour to be finalised in Session 7 discussion before implementation.

### Confirmed design decisions
- **One-time only** — pinned to the NEXT occurrence of the chosen tithi from creation date. Once that date passes or user marks complete → archived. No recurrence. (Recurring needs are served by existing Personal Events.)
- **Separate section from Events** — To-Dos are actionable tasks (donate, call someone, visit temple). Events are commemorations (birthdays, anniversaries). Different intent → different UI section.
- **Paywall**: fold To-Dos into the existing `MyEventsScreen` (Pro tab) — add a tabbed layout (Events | To-Dos) or a second section. Reuses existing `PremiumGuard` + sign-in check with zero new paywall logic. Paywall placement detail deferred to session.

### Data model (confirmed)
```dart
class UserTodo {
  final String id;              // UUID
  final String title;           // Required
  final String? notes;          // Optional
  final int tithi;              // 1–30 (next occurrence calculated at creation)
  final int? teluguMonth;       // null = any paksha | 1–12 = specific month
  final DateTime targetDate;    // Computed: next occurrence of tithi at creation time
  final bool isCompleted;       // User marks done
  final bool isActive;          // Soft delete
  final int? reminderHour;      // null = no reminder
  final int reminderMinute;
  final ReminderType reminderType;
}
```

### Architecture
- **`user_todo.dart`** — model, `toMap()`, `fromMap()`, `copyWith()`
- **`user_todo_provider.dart`** — CRUD + Hive (`userTodosBox`), single notification (not 3 occurrences)
- **`TodoFormScreen`** — reuses tithi picker + `_ReminderRow`; computes and stores `targetDate` on save
- **`MyEventsScreen`** — add Events | To-Dos tab bar; To-Dos section shows pending first, completed/past archived below
- **Day detail**: show matching To-Dos (where `targetDate` == that day) with checkbox

### Differences from Events
| | Events | To-Dos |
|--|--|--|
| Tithi-based | ✓ | ✓ |
| Recurrence | Every paksha or yearly | One-time only |
| Completion | N/A | ✓ Checkbox → archived |
| Notifications | Up to 3 future occurrences | Single notification |
| Intent | Commemorate | Act / task |

---

## NEXT SESSION — What to Work On

### CRITICAL (Blocking)
0. **Fix `zonedSchedule()` failure** — notifications broken. `zonedSchedule()` throws, error now surfaces via "Sched." button in Settings → Notifications. Read the error, then fix root cause. Do NOT guess — read the error first.

### High Priority
1. **Firestore Pro subscription check** — replace hardcoded email whitelist with real Firestore query. User's Pro status should come from their Firestore document, not a local email list.
2. **Festival markers on calendar grid** — `features.md` has two unchecked items: "Festival marker on calendar cells" and "Festival markers on grid". Pre-loaded festivals should show dots/indicators on the monthly calendar.
3. **Paywall screen** — `premium_guard.dart` shows a placeholder; wire up the actual subscription flow (RevenueCat or Google Play Billing).

### Deferred / Lower Priority
4. **Mantra splash speed** — call `runApp()` before heavy init; use a `StateProvider<bool>` "ready" flag. Heavy init (city DB, festivals, reschedule notifications) runs in background.
5. **Settings notification preferences** — let users toggle notification channel, default alarm vs reminder.
6. **Theme: light / dark** — currently only light theme.
7. **iOS support** — not yet started.
