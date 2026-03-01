# Panchangam Pro — Personal Tithi Events + Paywall
**Plan created:** Feb 28, 2026
**Tier:** ₹99/year Pro (billing deferred — features first, Subscribe button disabled)

---

## Goal

Let users create named tithi-based personal events (Guru birthdays, death anniversaries, family traditions) that appear on the calendar like festivals and trigger reminders.

---

## Session 1 — Data Foundation ✅ COMPLETE (Feb 28, 2026)

Branch: `feature/pro-session1-data-foundation` | Commit: `77f1603`

- [x] Create `app/assets/data/festivals.json` — all 31 festivals migrated
- [x] Create `app/lib/features/festivals/festival_loader.dart` — parse JSON → `List<Festival>`
- [x] Update `festival_calculator.dart` — uses `FestivalLoader.all`, falls back to `FestivalData.all` in CLI/tests
- [x] Archive `festival_data.dart` → `_archive/festival_data.dart.bak` (safe backup, NOT deleted)
- [x] Update `pubspec.yaml` — `assets/data/festivals.json` + `uuid: ^4.5.1`
- [x] Create `app/lib/features/events/user_tithi_event.dart` — model + toMap/fromMap + copyWith
- [x] Update `app/lib/core/utils/hive_keys.dart` — `userEventsBox` + `isPremium` keys added
- [x] Update `app/lib/main.dart` — opens `userEventsBox` + calls `FestivalLoader.initialize`
- [x] Create `app/lib/features/events/user_event_provider.dart` — CRUD + Hive JSON persistence
- [x] Run `dart run bin/validate.dart` — identical output ✅
- [x] All 32 unit tests passing ✅

---

## Session 2 — Calendar Integration ✅ COMPLETE (Feb 28, 2026)

Branch: `feature/pro-session2-calendar-integration` | Commit: `7e52895`

- [x] Create `user_event_calculator.dart` — tithi match (tithi + teluguMonth + isAdhika guard)
- [x] Extend `DayData` — `teluguMonthNumber`, `isAdhikaMaasa`, `hasPersonalEvent`, `personalEventNames`
- [x] Update `calendar_provider.dart` — overlays user events (gated by `isPremium`)
- [x] Update `day_cell.dart` — gold italic `· EventName` below nakshatra
- [x] Add `isPremium` to `AppSettings` + `setIsPremium()` to `SettingsNotifier`
- [x] Add debug toggle to `settings_screen.dart` (only visible in `kDebugMode`)
- [x] 32 unit tests pass ✅, no analyzer errors ✅

---

## Session 3 — Event UI ✅ COMPLETE (Feb 28, 2026)

Branch: `feature/pro-session3-event-ui` | Commits: `28e62aa`, `6cead70`, `29cc78c`

- [x] `premium_guard.dart` — shows child if isPremium, else upgrade teaser (Subscribe button disabled)
- [x] `my_events_screen.dart` — list (active first), swipe-to-delete, toggle, edit icon, FAB, empty state
- [x] `event_form_screen.dart` — name EN/TE, tithi picker (30 items), month picker (null=every paksha), reminder placeholder (TODO Session 4)
- [x] `personal_events_card.dart` — gold-bordered card for Today + Panchangam detail
- [x] `user_event_calculator.matchingEvents()` — added for PanchangamData context
- [x] `family_screen.dart` — two-branch: Pro→MyEventsScreen (owns Scaffold), Free→thin Scaffold+PremiumGuard
- [x] `today_screen.dart` — PersonalEventsCard shown when isPremium + matching events
- [x] `panchangam_screen.dart` — PersonalEventsCard + "Mark this tithi" gold FAB (isPremium-gated)
- [x] `routes.dart` — `/events/new?tithi=N` + `/events/:id` push routes added
- [x] 32 unit tests pass ✅, no analyzer errors ✅

---

## Session 4 — Notifications ✅ COMPLETE (Mar 1, 2026)

Branch: `feature/pro-session4-notifications` | Merged to main

- [x] `flutter pub add flutter_local_notifications` in `app/`
- [x] Update `AndroidManifest.xml` — `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` + receivers
- [x] Create `app/lib/services/notification_service.dart` — singleton: `init()`, `scheduleForEvent()`, `cancelForEvent()`
- [x] Add `nextOccurrences()` to `user_event_calculator.dart` — returns next N dates when event's tithi falls
- [x] Update `user_event_provider.dart` — schedule on add/update, cancel on delete/disable
- [x] Update `main.dart` — `NotificationService.init()` + re-schedule all active events on start
- [x] Wire real reminder dropdown in `event_form_screen.dart`
- [x] `flutter build apk --release` → 54.0 MB ✅, installed ✅

---

## Session 5 — Google Sign-In + Auth UX ✅ COMPLETE (Mar 1, 2026)

Branch: `feature/pro-session5-auth` → renamed `feature/pro-session5-auth` | Merged to main

- [x] Firebase Auth + Google Sign-In (google_sign_in v7 API)
- [x] Sign-in is OPTIONAL — unauthenticated users see full core app
- [x] `authStateProvider` = `StreamProvider<User?>` watching Firebase auth stream
- [x] `PanchangamApp` always renders MaterialApp (auth logic merged in, no separate AuthGate)
- [x] `LoginScreen` — app icon, language-aware title, `onSuccess: VoidCallback?`
- [x] Settings: `_SignInTile` + `_LoginSheet` bottom sheet (auto-closes on success)
- [x] Pro tab (`FamilyScreen`): auth check first → MyEventsScreen sign-in prompt if not logged in
- [x] My Events (`MyEventsScreen`): sign-in prompt when `user == null`
- [x] `SplashOverlay` hoisted to wrap entire `authAsync.when()` — mantra shows from first frame
- [x] Fixed `SplashOverlay` Stack missing Directionality (red error screen bug)
- [x] `flutter build apk --release` ✅, installed ✅

---

## Session 6 — Reminders Redesign + Notes + Alarm Type ✅ COMPLETE (Mar 1, 2026)

Branch: `feature/event-reminders-and-notes` | Merged to main

- [x] `UserTithiEvent`: `reminderMinutes` → `reminderHour?` + `reminderMinute` + `reminderDaysBefore` + `reminderType`
- [x] `UserTithiEvent`: added `notes: String?`
- [x] `NotificationService`: fires at user-chosen time N days before tithi (not sunrise-based)
- [x] `NotificationService`: `ReminderType.reminder` → `inexact`; `ReminderType.alarm` → `alarmClock`
- [x] `NotificationService`: improved `_title()` + `_body()` (timing context + notes snippet)
- [x] `EventFormScreen`: toggle → SegmentedButton (Reminder/Alarm) + time picker + days dropdown + notes field
- [x] `PersonalEventsCard` (`_EventEntry`): expandable notes (StatefulWidget, chevron, gold container)
- [x] `MyEventsScreen` (`_EventTile`): expandable notes (ConsumerStatefulWidget)
- [x] Backwards-compatible: old events load with `reminderHour: null` (no reminder)
- [x] `flutter build apk --release` → 57.9 MB ✅, installed ✅

---

## Data Model (current)

```dart
enum ReminderType { reminder, alarm }

class UserTithiEvent {
  final String id;               // UUID
  final String nameEn;           // User-given name (required)
  final String? nameTe;          // Optional Telugu name
  final int tithi;               // 1–30 (matches Tithi.number() output directly)
  final int? teluguMonth;        // null = recurs every paksha | 1–12 = yearly only
  final int? reminderHour;       // null = no reminder | 0–23
  final int reminderMinute;      // 0–59 (default 0)
  final int reminderDaysBefore;  // 0 = same day, 1 = day before, etc.
  final ReminderType reminderType; // reminder (inexact) | alarm (alarmClock exact)
  final String? notes;           // Optional free-text note
  final bool isActive;           // toggle off without deleting
  final String color;            // hex for calendar dot (default: kGold '#FFD700')
}
```

---

## Session 7 — Next Up

### Do First (Housekeeping)
- [ ] **Doc reorganization** — all `.md` files capped at 200 lines. Microservices-style: one responsibility per file, consistent naming, cross-links. Files currently at/near limit: `LatestTask.md` (221), `lessons.md` (199), `todo.md` (180), `features.md` (170). Split before any feature work.

### Must Do
- [ ] **Alarm sound** — `ReminderType.alarm` sounds same as reminder. Add `panchangam_alarms` channel with `AudioAttributesUsage.alarm` + system alarm ringtone. Use for alarm mode only.
- [ ] **To-Do feature (Pro)** — **Tithi-based** to-dos (same date basis as Events) with completion checkbox + optional reminder. Discuss exact recurrence model before implementing. See LatestTask.md for rough plan.
- [ ] **Festival markers on calendar grid** — gold dot or indicator on days with festivals in the monthly calendar grid
- [ ] **Firestore Pro subscription check** — replace hardcoded email whitelist with real Firestore document check

### Deferred
- [ ] Paywall / subscription screen (RevenueCat or Google Play Billing)
- [ ] Notification settings in Settings tab (default mode: reminder vs alarm)
- [ ] Theme: light / dark
- [ ] Mantra splash speed-up (call runApp() before heavy init)
- [ ] iOS release (after Android stable)

---

## Architecture Notes

- `isPremium` stored in `settings` Hive box (not a separate box); auto-set from email whitelist in `AuthService`
- User events stored as JSON strings in `userEventsBox` Hive box (UUID key, no TypeAdapters)
- `UserEventCalculator` reuses same tithi-check logic as `FestivalCalculator`
- `PremiumGuard` wraps gated UI — shows child if premium, else upgrade teaser
- `NotificationService` singleton: init at app start, schedule on event add/edit, cancel on delete/disable
- Notification ID = `eventId.hashCode ^ (occurrenceIndex * 31)` to avoid collisions
- `SCHEDULE_EXACT_ALARM` already in `AndroidManifest.xml` (needed for `alarmClock` mode)

---

## Verification Checklist (End of All Sessions)

- [x] `dart run bin/validate.dart` → identical output to before JSON migration
- [x] All 32 unit tests pass
- [x] Add personal event → gold dot on correct tithi dates on calendar
- [x] Edit event → calendar updates, notifications rescheduled
- [x] Delete event → dot gone, notifications cancelled
- [x] Today screen shows personal events on matching days
- [x] "Mark this tithi" on Panchangam detail pre-fills form
- [x] Free user hitting premium feature → PaywallScreen shown
- [x] Debug unlock (isPremium=true) → all features accessible
- [x] Notes field on event form → saved + shown in expandable card (My Events + Day card)
- [x] Reminder/Alarm selector in form → correct notification mode used
- [x] `flutter build apk --release` succeeds
- [ ] Real Google Sign-In on device → Pro auto-granted ✅ (tested by Srikar)
- [ ] Festival markers on calendar grid
- [ ] Notification fires at correct time (device test)
