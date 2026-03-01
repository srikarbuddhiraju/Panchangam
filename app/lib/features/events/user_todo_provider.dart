import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/hive_keys.dart';
import '../../services/notification_service.dart';
import '../settings/settings_provider.dart';
import 'user_event_calculator.dart';
import 'user_tithi_event.dart' show ReminderType;
import 'user_todo.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final userTodoProvider =
    NotifierProvider<UserTodoNotifier, List<UserTodo>>(
  UserTodoNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class UserTodoNotifier extends Notifier<List<UserTodo>> {
  static const _uuid = Uuid();

  @override
  List<UserTodo> build() => _loadAll();

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// All active, not-completed To-Dos (shown at the top of the list).
  List<UserTodo> get pending =>
      state.where((t) => t.isActive && !t.isCompleted).toList();

  /// Completed or past To-Dos still in active state (shown below pending).
  List<UserTodo> get archived =>
      state.where((t) => t.isActive && t.isCompleted).toList();

  // ── Writes ─────────────────────────────────────────────────────────────────

  /// Add a new To-Do. Computes [targetDate] from the next occurrence of [tithi].
  ///
  /// Returns null if no occurrence is found within 400 days.
  Future<UserTodo?> add({
    required String title,
    String? notes,
    required int tithi,
    int? teluguMonth,
    int? reminderHour,
    int reminderMinute = 0,
    ReminderType reminderType = ReminderType.reminder,
  }) async {
    final settings = ref.read(settingsProvider);
    final targetDate = UserEventCalculator.nextOccurrenceDate(
      tithi,
      teluguMonth,
      DateTime.now(),
      settings.lat,
      settings.lng,
    );
    if (targetDate == null) return null;

    final todo = UserTodo(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      tithi: tithi,
      teluguMonth: teluguMonth,
      targetDate: targetDate,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      reminderType: reminderType,
    );

    await _save(todo);
    state = [...state, todo];
    _scheduleNotification(todo);
    return todo;
  }

  /// Mark a To-Do as complete (or un-complete if [done] is false).
  Future<void> complete(String id, {bool done = true}) async {
    final todo = state.where((t) => t.id == id).firstOrNull;
    if (todo == null) return;
    final updated = todo.copyWith(isCompleted: done);
    await _save(updated);
    state = [for (final t in state) if (t.id == id) updated else t];
    if (done) {
      NotificationService.instance.cancelForTodo(id).ignore();
    } else if (updated.reminderHour != null) {
      _scheduleNotification(updated);
    }
  }

  /// Update an existing To-Do (e.g., after editing title/notes/reminder).
  Future<void> update(UserTodo updated) async {
    await _save(updated);
    state = [for (final t in state) if (t.id == updated.id) updated else t];
    NotificationService.instance.cancelForTodo(updated.id).then((_) {
      if (!updated.isCompleted && updated.reminderHour != null) {
        _scheduleNotification(updated);
      }
    }).ignore();
  }

  /// Permanently delete a To-Do.
  Future<void> delete(String id) async {
    final box = Hive.box(HiveKeys.userTodosBox);
    await box.delete(id);
    state = state.where((t) => t.id != id).toList();
    NotificationService.instance.cancelForTodo(id).ignore();
  }

  // ── Notification helper ────────────────────────────────────────────────────

  void _scheduleNotification(UserTodo todo) {
    if (todo.reminderHour == null || todo.isCompleted) return;
    final body = todo.notes != null && todo.notes!.isNotEmpty
        ? (todo.notes!.length > 80
            ? '${todo.notes!.substring(0, 77)}…'
            : todo.notes!)
        : null;
    NotificationService.instance.scheduleForTodo(
      id: todo.id,
      title: todo.title,
      body: body,
      targetDate: todo.targetDate,
      reminderHour: todo.reminderHour!,
      reminderMinute: todo.reminderMinute,
      isAlarm: todo.reminderType == ReminderType.alarm,
    ).ignore();
  }

  // ── Persistence helpers ────────────────────────────────────────────────────

  List<UserTodo> _loadAll() {
    final box = Hive.box(HiveKeys.userTodosBox);
    final List<UserTodo> result = [];
    for (final key in box.keys) {
      try {
        final raw = box.get(key) as String?;
        if (raw == null) continue;
        result.add(UserTodo.fromMap(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // Skip malformed entries
      }
    }
    return result;
  }

  Future<void> _save(UserTodo todo) async {
    final box = Hive.box(HiveKeys.userTodosBox);
    await box.put(todo.id, jsonEncode(todo.toMap()));
  }
}
