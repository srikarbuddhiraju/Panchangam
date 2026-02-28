import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/hive_keys.dart';
import 'user_tithi_event.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

/// All user tithi events, loaded from Hive.
///
/// Returns an empty list if the box has no events yet.
/// This provider is used by calendar, Today, and Panchangam detail screens.
final userEventProvider =
    NotifierProvider<UserEventNotifier, List<UserTithiEvent>>(
  UserEventNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class UserEventNotifier extends Notifier<List<UserTithiEvent>> {
  static const _uuid = Uuid();

  @override
  List<UserTithiEvent> build() {
    return _loadAll();
  }

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// All events (active and inactive).
  List<UserTithiEvent> get all => state;

  /// Only active events (shown on calendar + Today screen).
  List<UserTithiEvent> get active =>
      state.where((e) => e.isActive).toList();

  // ── Writes ─────────────────────────────────────────────────────────────────

  /// Add a new event. Returns the created event.
  Future<UserTithiEvent> add({
    required String nameEn,
    String? nameTe,
    required int tithi,
    int? teluguMonth,
    int? reminderMinutes,
    String color = '#FFD700',
  }) async {
    final event = UserTithiEvent(
      id: _uuid.v4(),
      nameEn: nameEn,
      nameTe: nameTe,
      tithi: tithi,
      teluguMonth: teluguMonth,
      reminderMinutes: reminderMinutes,
      isActive: true,
      color: color,
    );
    await _save(event);
    state = [...state, event];
    // TODO(Session4): NotificationService.scheduleNext(event)
    return event;
  }

  /// Update an existing event by id. No-op if id not found.
  Future<void> update(UserTithiEvent updated) async {
    await _save(updated);
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e,
    ];
    // TODO(Session4): NotificationService.cancelAll(updated.id) then reschedule
  }

  /// Toggle active/inactive without deleting.
  Future<void> toggleActive(String id) async {
    final event = state.where((e) => e.id == id).firstOrNull;
    if (event == null) return;
    await update(event.copyWith(isActive: !event.isActive));
  }

  /// Permanently delete an event.
  Future<void> delete(String id) async {
    final box = Hive.box(HiveKeys.userEventsBox);
    await box.delete(id);
    state = state.where((e) => e.id != id).toList();
    // TODO(Session4): NotificationService.cancelAll(id)
  }

  // ── Persistence helpers ────────────────────────────────────────────────────

  List<UserTithiEvent> _loadAll() {
    final box = Hive.box(HiveKeys.userEventsBox);
    final List<UserTithiEvent> result = [];
    for (final key in box.keys) {
      try {
        final raw = box.get(key) as String?;
        if (raw == null) continue;
        final map = jsonDecode(raw) as Map<String, dynamic>;
        result.add(UserTithiEvent.fromMap(map));
      } catch (_) {
        // Skip malformed entries — never crash on bad stored data
      }
    }
    return result;
  }

  Future<void> _save(UserTithiEvent event) async {
    final box = Hive.box(HiveKeys.userEventsBox);
    await box.put(event.id, jsonEncode(event.toMap()));
  }
}
