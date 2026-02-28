# Panchangam Pro — Personal Tithi Events + Paywall
**Plan created:** Feb 28, 2026
**Tier:** ₹99/year Pro (billing deferred — features first, Subscribe button disabled)

---

## Goal

Let users create named tithi-based personal events (Guru birthdays, death anniversaries, family traditions) that appear on the calendar like festivals and trigger reminders.

---

## Session 1 — Data Foundation ✅ COMPLETE (Feb 28, 2026)

Branch: `feature/pro-session1-data-foundation`

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

Branch: `feature/pro-session2-calendar-integration`

- [x] Create `user_event_calculator.dart` — tithi match (tithi + teluguMonth + isAdhika guard)
- [x] Extend `DayData` — `teluguMonthNumber`, `isAdhikaMaasa`, `hasPersonalEvent`, `personalEventNames`
- [x] Update `calendar_provider.dart` — overlays user events (gated by `isPremium`)
- [x] Update `day_cell.dart` — gold italic `· EventName` below nakshatra
- [x] Add `isPremium` to `AppSettings` + `setIsPremium()` to `SettingsNotifier`
- [x] Add debug toggle to `settings_screen.dart` (only visible in `kDebugMode`)
- [x] 32 unit tests pass ✅, no analyzer errors ✅

---

## Session 3 — Event UI

- [ ] Create `app/lib/features/events/my_events_screen.dart` — Family tab: list + empty state + FAB
- [ ] Create `app/lib/features/events/event_form_screen.dart` — add/edit form
- [ ] Create `app/lib/features/premium/premium_guard.dart` — PremiumGuard widget
- [ ] Update `today_screen.dart` — show user events alongside festivals
- [ ] Update `panchangam_screen.dart` — "Mark this tithi" FAB (premium-gated, pre-fills tithi)
- [ ] Update `family_screen.dart` — replace Coming Soon teaser → MyEventsScreen
- [ ] Update `routes.dart` — add `/events/new` and `/events/:id` push routes
- [ ] **Verify:** Full add → view on calendar → view on today → edit → delete flow

---

## Session 4 — Notifications

- [ ] Create `app/lib/services/notification_service.dart` — flutter_local_notifications wrapper
- [ ] Update `AndroidManifest.xml` — add POST_NOTIFICATIONS + SCHEDULE_EXACT_ALARM permissions
- [ ] On event save: schedule next 3 occurrences via NotificationService
- [ ] On event delete/disable: cancel notifications
- [ ] On app start: re-schedule all active events
- [ ] **Verify:** Add event with near-future reminder → notification fires correctly

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

## Festival JSON Schema

```json
{
  "version": 1,
  "festivals": [
    {
      "nameTe": "ఉగాది", "nameEn": "Ugadi",
      "type": "tithi",
      "teluguMonth": 1, "paksha": 1, "tithi": 1,
      "observedAtNight": false,
      "descriptionEn": "Telugu New Year..."
    },
    {
      "nameTe": "భోగి", "nameEn": "Bhogi",
      "type": "solar",
      "gregorianMonth": 1, "gregorianDay": 13,
      "descriptionEn": "The day before Sankranti..."
    }
  ]
}
```

---

## Architecture Notes

- `isPremium` stored in `settings` Hive box (not a separate box)
- User events stored as JSON strings in `userEventsBox` Hive box (UUID key, no TypeAdapters)
- `UserEventCalculator` reuses same tithi-check logic as `FestivalCalculator`
- `PremiumGuard` wraps gated UI — shows child if premium, else PaywallScreen
- `NotificationService` singleton: init at app start, schedule on event add/edit, cancel on delete/disable

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
