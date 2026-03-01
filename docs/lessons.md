# Claude Lessons — Panchangam Project

Running log of mistakes, corrections, and patterns to avoid repeating.
Updated after every user correction, per CLAUDE.md Self-Improvement Loop.

---

## Calculation Accuracy

### Samvatsara anchor was wrong
- **Mistake**: Calibration anchor was wrong
- **Fix**: Anchor = Visvavasu = Shaka 1947 index 38
- **Rule**: Always anchor samvatsara to a known verified reference, not derived math

### Yamaganda multiplier was wrong
- **Mistake**: Saturday multiplier was 7 (position P8)
- **Fix**: Should be 5 (position P6), per Pillai table [4,3,2,1,0,7,5]
- **Rule**: For kalam timings, always verify against the published table, not intuition

### Karana off-by-one in 60-karana sequence
- **Mistake**: Formula was `(seq-1)%7`, Kimstughna was in wrong position
- **Fix**: Formula is `(seq-2)%7`; seq 1 = Kimstughna is fixed
- **Rule**: Off-by-one errors in modular arithmetic are easy to miss — always verify with known examples (Amavasya karana, etc.)

### Ugadi kshaya logic was wrong (lookback approach)
- **Mistake**: Was using a lookback from T2 to T30 which was structurally wrong
- **Fix**: T30 at sunrise + T2 next day → Ugadi = today
- **Rule**: For festival logic, build forward from the correct definition, not backward from symptoms

### Telugu monthNumber was solar approximation
- **Mistake**: Was using solar position approximation for month number
- **Fix**: Correct Amavasyant = find next Amavasya → read sun rashi
- **Rule**: Telugu months are lunar (Amavasyant), not solar — never conflate the two

---

## UI / Navigation

### Calendar flicker
- **Mistake**: monthDataProvider was autoDispose, causing rebuild on every navigation
- **Fix**: Removed autoDispose + added `skipLoadingOnReload: true`
- **Rule**: Providers that back large grids must NOT be autoDispose; they get rebuilt too often

### Telugu locale crash
- **Mistake**: Used `DateFormat('te')` without initializing locale
- **Fix**: Call `initializeDateFormatting('te')` in main() before runApp
- **Rule**: Any non-default locale with intl must be initialized explicitly

### No back button on day detail
- **Mistake**: Used `context.go()` which replaced the navigation stack
- **Fix**: Changed to `context.push()` in calendar_grid.dart
- **Rule**: `go()` = replace stack (no back button). `push()` = add to stack (back works). Use push for drill-down navigation.

---

## Adhika Maasa

### Naming rule: Adhika uses FOLLOWING Nija month's name
- **Confirmed**: Traditional rule is Adhika month = same name as the following Nija month
- **Implementation**: `monthNumber()` for Adhika uses nextNextAm's rashi, not nextAm's rashi
- **Rule**: Never use the preceding month's name for Adhika — it's always named after what comes after

---

## Token Efficiency

### Do not read blindly into docs
- **Rule**: Skim and scan first to find what you need. Only read deeply if absolutely required.
- Don't open a full file/image to extract one value — target what you need first.

### Subagent for simple targeted searches = wasteful
- **Mistake**: Launched an Explore subagent to find Amruthakalam code — used 45k tokens
- **Fix**: Use direct Grep/Glob for known targets (file names, class names, function names)
- **Rule**: Reserve subagents for open-ended, multi-file exploration. For targeted searches, use Grep/Glob directly.

### Web search for reference data = wasteful
- **Mistake**: Attempted WebSearch for traditional Amrit Kalam table
- **Fix**: Ask the user to fetch the info (e.g., check DrikPanchang manually) and paste it
- **Rule**: If you need external reference data (tables, spec pages, external URLs), ask the user to fetch and paste it. Do not use WebSearch for large lookups.

---

## Screenshots / Documentation

### Screenshot naming must match content
- **Rule**: Always verify screenshot content before naming. Filename must accurately describe what's on screen.

---

## Dart / Build

### dart analyze can miss missing imports that the compiler catches
- **Mistake**: Three files used `UserTithiEvent` without importing `user_tithi_event.dart`. MCP `analyze_files` reported "No errors" but `flutter build apk --release` failed with `'UserTithiEvent' isn't a type.`
- **Fix**: Add the missing import to each affected file.
- **Rule**: Always do a full release build before declaring a session complete — the compiler catches things the analysis server can miss due to caching.

---

## Dart Syntax

### Local functions cannot have `final` modifier
- **Mistake**: Wrote `final String fmt(DateTime dt) => ...` inside a build() method
- **Fix**: Local functions are just `String fmt(DateTime dt) => ...` — no modifier
- **Rule**: In Dart, `final` applies to variables, not local function declarations

---

## Git Branching (MANDATORY)

### Always use feature branches
- **Rule**: NEVER implement features or sessions directly on main. Create a branch first.
- **Rule**: Naming convention: `feature/<short-description>` (e.g., `feature/pro-session1-data-foundation`)
- **Rule**: Merge to main only when session is complete and verified with tests + build
- **Rule**: For Pro feature sessions, one branch per session. Smaller branches for bug fixes.
- This is a standing instruction from Srikar — applies to ALL future sessions.

---

## Flutter Widget Architecture

### Double-Scaffold — two Scaffolds stacked = two AppBars
- **Mistake**: `FamilyScreen` had its own `Scaffold+AppBar`, and it was rendering `MyEventsScreen` (which also had a `Scaffold+AppBar`) inside its body. This stacks two AppBars on screen.
- **Fix**: Two-branch approach — if Pro, return `MyEventsScreen()` directly (it owns the Scaffold). If free, return a thin `Scaffold + PremiumGuard` (no child Scaffold inside).
- **Rule**: A widget that contains its own `Scaffold` must NOT be embedded inside another `Scaffold`'s body. If a screen owns its own layout (AppBar + FAB + body), the parent should return it directly, not wrap it.

---

## Android Notifications (CRITICAL — tricky platform behaviour)

### requestNotificationsPermission() must not be called before runApp()
- **Mistake**: Called `requestNotificationsPermission()` inside `NotificationService.init()`, which runs before `runApp()` in `main()`. No Activity exists at that point, so the system permission dialog is never shown → POST_NOTIFICATIONS never granted → all notifications silently dropped.
- **Fix**: Remove the call from `init()`. Add a `requestPermissions()` method and call it via `WidgetsBinding.instance.addPostFrameCallback((_) { ... })` AFTER `runApp()` so an Activity is live.
- **Rule**: Any platform API that requires an Activity (permission dialogs, system intents) must be called AFTER `runApp()`. Pre-runApp code has no Activity context.

### Battery-optimization dialog must only show once — store a Hive flag
- **Mistake**: Called `requestIgnoreBatteryOptimizations` on every app start (via `addPostFrameCallback`). Even after granting, the check might return false on Samsung, re-showing the dialog every launch.
- **Fix**: Add `HiveKeys.batteryOptAsked` (bool) to the settingsBox. Read it in `main.dart` before calling `requestPermissions()`. Pass `askBatteryOpt: false` on subsequent launches. Set the flag to `true` after the first prompt.
- **Rule**: Any one-time system dialog (battery opt, rating prompt, onboarding) must be gated behind a persisted "already asked" flag. Never re-show them on each app start.

### ScheduledNotificationBootReceiver must be exported=true on Android 12+
- **Mistake**: Boot receiver declared `android:exported="false"`. On Android 12+, system broadcasts (BOOT_COMPLETED, MY_PACKAGE_REPLACED) are NOT delivered to receivers with `exported=false`. Notifications never recovered after device reboot.
- **Fix**: Set `android:exported="true"` on the boot receiver. The ScheduledNotificationReceiver (used by AlarmManager explicit intents) can stay `exported=false`.
- **Rule**: Any receiver with an intent-filter for system broadcasts (BOOT_COMPLETED, PACKAGE_REPLACED etc.) MUST be `exported=true` on Android 12+.

### R8 v3+ breaks GSON TypeToken — requires two specific `-keep,allowobfuscation,allowshrinking` rules
- **Symptom**: `zonedSchedule()` throws `PlatformException: Missing type parameter` in release builds only. Debug builds work fine. `show()` (immediate) always works.
- **Exact cause**: `flutter_local_notifications` creates `new TypeToken<List<NotificationDetails>>() {}` in `loadScheduledNotifications()`. R8 v3+ removes the `Signature` attribute from TypeToken anonymous subclasses even when `-keepattributes Signature` is set, unless two specific rules (from GSON 2.9.1 official R8 guidance) are present.
- **Insufficient fix**: `-keep class com.dexterous.flutterlocalnotifications.** { *; }` + `-keepattributes Signature` — not enough for R8 v3+.
- **Correct fix** (from GSON official R8 docs):
  ```
  -keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
  -keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
  ```
  These preserve generic signatures on ALL TypeToken subclasses. The `allowobfuscation` lets R8 rename them; `allowshrinking` lets R8 remove unused ones. But R8 MUST preserve the class structure (Signature) to allow TypeToken to introspect the generic type via reflection.
- **File**: `android/app/proguard-rules.pro`
- **Rule**: For any Flutter release build using `flutter_local_notifications` with `zonedSchedule()`: add `proguard-rules.pro` with the GSON TypeToken rules above. The plugin ships NO consumer ProGuard rules of its own.

### canScheduleExactAlarms() is canScheduleExactNotifications() in v18
- **Mistake**: Called `canScheduleExactAlarms()` which doesn't exist in flutter_local_notifications v18. Build failed.
- **Fix**: The correct method name in v18 is `canScheduleExactNotifications()`.
- **Rule**: Always verify exact API method names against the installed package version — don't assume from docs for a different version. Use `grep` on the pub-cache source before writing.

### Alarm mode (alarmClock) silently fails without SCHEDULE_EXACT_ALARM grant
- **Mistake**: Used `AndroidScheduleMode.alarmClock` without checking if `SCHEDULE_EXACT_ALARM` was granted. The exception was swallowed by `catch (_)`, so the notification silently disappeared.
- **Fix**: Call `canScheduleExactNotifications()` before scheduling; fall back to `inexact` if not granted. Show a dialog guiding the user to Settings → Apps → Special app access → Alarms & reminders.
- **Rule**: Never silently swallow permission-related exceptions for features the user explicitly enabled. Either fall back with a user-visible notice, or surface the error.

### Battery optimization kills inexact reminders on Samsung/MIUI
- **Root cause**: Inexact alarms use `AlarmManager.set()` which can be deferred during deep doze. Samsung's aggressive battery optimization routinely kills these before they fire.
- **Fix**: Added `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission to manifest. Added `panchangam/system` MethodChannel in `MainActivity.kt` to check `isIgnoringBatteryOptimizations` and call `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent. Called from `requestPermissions()` at app start.
- **Note**: `alarmClock` mode (exact alarms) IS exempt from doze — that's why alarm mode works without battery exemption.
- **Rule**: For reliable background notifications on any Android device, request battery-optimization exemption early. Add the MethodChannel to MainActivity.kt at project setup, not after.

---

## Debugging Discipline (CRITICAL)

### Do NOT apply fixes without knowing the root cause
- **Mistake**: Applied 4+ rounds of notification fixes (manifest changes, permission flow, battery opt, MethodChannel) while `zonedSchedule()` was silently failing with an unread exception. Each fix addressed peripheral issues while the core error was never surfaced.
- **Mistake**: User said "strategize, think then act" — but the next action was still a guess rather than first surfacing the actual error.
- **Root rule**: When something silently fails, the FIRST action must be to make it fail loudly. `catch (_)` hides the real problem. Surface the exception, read it, THEN fix it.
- **Consequence**: Multiple builds, multiple installs, wasted sessions, frustrated user.
- **Rule**: Before writing any fix for a broken feature: (1) remove silent catches, (2) surface the error to the UI or logcat, (3) read the error, (4) only then write the fix.

### Silent `catch (_)` is the enemy of debugging
- **Pattern**: `catch (_) { // silently skip }` in scheduling code means errors vanish completely.
- **Rule**: In production code, a scheduling failure should at minimum log the error. During debugging, it must surface to the UI. Never use bare `catch (_)` for code paths that involve platform APIs.

---

## Data Persistence (CRITICAL)

### Never lose user-pasted data between sessions
- **Mistake**: User pasted Sringeri PDF entries (nakshatra data, amrit kalam offsets, etc.) during a session. I processed it in context but did NOT save it to a file. When the session ended, the data was lost. I then asked the user to paste it again — completely unacceptable.
- **Fix**: The moment a user pastes any reference data (PDF content, table entries, corrections, lookup values), IMMEDIATELY write it to a file in `docs/data/` or update the relevant source file. Do not wait until "later in the session."
- **Rule**: If the user pastes it, it gets saved to disk. No exceptions. Context is ephemeral. Files are permanent.
- **Rule**: After saving, confirm to the user: "Saved to docs/data/amrit_kalam_entries.md" so they know it's persisted.

---
