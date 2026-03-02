# Claude Lessons — Platform & Debugging (Panchangam)

Critical lessons from Android notifications and debugging failures.
← Back to [lessons.md](lessons.md)

---

## Debugging Discipline (CRITICAL)

### Surface the error BEFORE writing any fix
- **Rule**: When something silently fails — step 1 is ONLY to make it fail loudly. Remove `catch (_)`, add a SnackBar, read logcat. Then fix.
- **Consequence of ignoring**: 4+ rounds of wrong fixes, multiple wasted sessions, frustrated user.

### Never use `.ignore()` on user-facing async calls
- **Mistake**: `_scheduleNotifications(event).ignore()` silenced every scheduling error for multiple sessions
- **Fix**: `unawaited(call.catchError((e) => debugPrint('schedule: $e')))`
- **Rule**: `.ignore()` only when zero user-visible effect. Notifications, persistence, permissions = always log or rethrow.

### Silent `catch (_)` is the enemy of debugging
- **Rule**: `catch (_) { }` on platform API paths is forbidden. At minimum: `catch (e) { debugPrint('$e'); }`. During debugging: surface to UI.

### Ship diagnostic/test UI on day 1 for any system-level feature
- **Mistake**: No test button for notifications until the feature was already broken across multiple sessions
- **Rule**: Any feature that can't be verified in 10 seconds needs a test button in the first build.

### Diagnose → propose → confirm → implement. In that order.
- Never chain fix attempts without user confirmation between them
- Never install a new build while the previous one hasn't been tested

### Unchecked verification items block merges
- **Mistake**: `[ ] Notification fires at correct time` sat unchecked across 3 merged sessions
- **Rule**: Unchecked = failing test = blocks merge. No exceptions.

---

## Android Notifications (CRITICAL — tricky platform behaviour)

### requestNotificationsPermission() must not be called before runApp()
- **Mistake**: Called inside `NotificationService.init()` before `runApp()` — no Activity → permission dialog never shown → all notifications silently dropped
- **Fix**: Move to `WidgetsBinding.instance.addPostFrameCallback` AFTER `runApp()`
- **Rule**: Any platform API requiring an Activity must be called AFTER `runApp()`

### Battery-optimization dialog must only show once — store a Hive flag
- **Fix**: `HiveKeys.batteryOptAsked` (bool) in settingsBox — prompt only on first launch
- **Rule**: Any one-time system dialog must be gated behind a persisted "already asked" flag

### ScheduledNotificationBootReceiver must be exported=true on Android 12+
- **Rule**: Any receiver with an intent-filter for system broadcasts MUST be `exported=true` on Android 12+

### canScheduleExactAlarms() is canScheduleExactNotifications() in v18
- **Rule**: Always grep pub-cache source for exact method name before writing any plugin call

### Alarm mode (alarmClock) silently fails without SCHEDULE_EXACT_ALARM grant
- **Fix**: Call `canScheduleExactNotifications()` first; fall back to `inexact` + show settings dialog
- **Rule**: Never silently swallow permission-related exceptions for user-enabled features

### Battery optimization kills inexact reminders on Samsung/MIUI
- **Fix**: `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` + MethodChannel in `MainActivity.kt`
- **Note**: `alarmClock` mode IS doze-exempt — only `inexact` needs battery opt exemption

### Notification channels are immutable — design ALL channels before first device install
- **Mistake**: Shipped one channel for both reminder and alarm — alarm sounds wrong, can't fix on existing installs
- **Rule**: Define ALL channels (with correct `AudioAttributesUsage`, importance, sound) before first real-device install

### R8 v3+ breaks GSON TypeToken — two specific keep rules required
- **Symptom**: `zonedSchedule()` throws `PlatformException: Missing type parameter` in release only
- **Root cause**: R8 strips Signature from TypeToken anonymous subclasses even with `-keepattributes Signature`
- **Correct fix** (GSON 2.9.1 official R8 guidance):
  ```
  -keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
  -keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
  ```
- **Rule**: `-keepattributes Signature` alone is NOT enough for R8 v3+. Check library GitHub issues before writing ProGuard rules.

### Release builds are a different environment — always test `--release`
- R8, ProGuard, reflection all behave differently. "Works in debug" means nothing for release-only failures.
