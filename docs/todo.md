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
- [x] `app/.gitignore` — refined: specific paywall files, allows `premium_guard.dart`
- [x] 32 unit tests pass ✅, no analyzer errors ✅

---

## Session 4 — Notifications (NEXT)

Branch to create: `feature/pro-session4-notifications`

**Do merges first** (Sessions 1→2→3→main), then create this branch.

- [ ] `flutter pub add flutter_local_notifications` in `app/`
- [ ] Update `AndroidManifest.xml` — add `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` permissions + receivers
- [ ] Create `app/lib/services/notification_service.dart` — singleton: `init()`, `scheduleForEvent()`, `cancelForEvent()`
- [ ] Add `nextOccurrences()` to `user_event_calculator.dart` — returns next N dates when event's tithi falls
- [ ] Update `user_event_provider.dart` — schedule on add/update, cancel on delete/disable
- [ ] Update `main.dart` — `NotificationService.init()` + re-schedule all active events on start
- [ ] Wire real reminder dropdown in `event_form_screen.dart` (30min, 1hr, 2hr, 6hr, 12hr, 1day, or none)
- [ ] **Verify on device**: add event with near-future reminder → notification fires ✅

---

## Session 5 — Paywall + Polish

- [ ] Re-track `paywall_screen.dart`, update pricing (₹99 Pro / ₹119 Family)
- [ ] Festival reminder opt-in in Settings (premium-gated)
- [ ] Full free-user flow test: blocked → upgrade prompt → debug unlock → all works
- [ ] `flutter build apk --release` → install → full test on device
- [ ] Commit + push to main

---

## Data Model

```dart
class UserTithiEvent {
  final String id;            // UUID
  final String nameEn;        // User-given name (required)
  final String? nameTe;       // Optional Telugu name
  final int tithi;            // 1–30 (matches Tithi.number() output directly)
  final int? teluguMonth;     // null = recurs every paksha | 1–12 = yearly only
  final int? reminderMinutes; // null = no reminder | N = remind N minutes before
  final bool isActive;        // toggle off without deleting
  final String color;         // hex for calendar dot (default: kGold)
}
```

---

## Architecture Notes

- `isPremium` stored in `settings` Hive box (not a separate box)
- User events stored as JSON strings in `userEventsBox` Hive box (UUID key, no TypeAdapters)
- `UserEventCalculator` reuses same tithi-check logic as `FestivalCalculator`
- `PremiumGuard` wraps gated UI — shows child if premium, else upgrade teaser
- `NotificationService` singleton: init at app start, schedule on event add/edit, cancel on delete/disable
- Notification ID = `eventId.hashCode ^ (occurrenceIndex * 31)` to avoid collisions

---

## Verification Checklist (End of All Sessions)

- [ ] `dart run bin/validate.dart` → identical output to before JSON migration
- [ ] All 32 unit tests pass
- [ ] Add personal event → gold dot on correct tithi dates on calendar
- [ ] Edit event → calendar updates, notifications rescheduled
- [ ] Delete event → dot gone, notifications cancelled
- [ ] Today screen shows personal events on matching days
- [ ] "Mark this tithi" on Panchangam detail pre-fills form
- [ ] Free user hitting premium feature → PaywallScreen shown
- [ ] Debug unlock (isPremium=true) → all features accessible
- [ ] Notification fires at correct time
- [ ] `flutter build apk --release` succeeds
- [ ] festivals.json covers all ~40 existing festivals (spot-check 10)
