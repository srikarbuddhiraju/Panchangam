import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/events/user_tithi_event.dart'
    show UserTithiEvent, ReminderType;

/// Handles scheduling and cancelling local notifications for personal tithi events.
///
/// Initialise once in main() via [init].
/// Schedule/cancel when events are saved or toggled via [UserEventProvider].
///
/// Notification ID formula: `event.id.hashCode ^ (occurrenceIndex * 31)`
/// Up to 3 future occurrences are scheduled per event.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'panchangam_events';
  static const _channelName = 'Personal Events';
  static const _channelDesc =
      'Reminders for your personal tithi events';

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // IST is the only timezone needed — India-only app.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Request POST_NOTIFICATIONS permission (Android 13+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedule up to [maxOccurrences] notifications for [event].
  ///
  /// Each notification fires at [event.reminderHour]:[event.reminderMinute]
  /// on the day that is [event.reminderDaysBefore] days before the tithi date.
  /// Occurrences already in the past are skipped silently.
  ///
  /// No-op if [event.reminderHour] is null.
  Future<void> scheduleForEvent(
    UserTithiEvent event,
    List<DateTime> occurrences,
    double lat,
    double lng, {
    int maxOccurrences = 3,
  }) async {
    if (event.reminderHour == null) return;

    final now = DateTime.now();
    int scheduled = 0;

    for (int i = 0; i < occurrences.length && scheduled < maxOccurrences; i++) {
      final tithiDate = occurrences[i];
      final notifyDate =
          tithiDate.subtract(Duration(days: event.reminderDaysBefore));
      final notifyAt = DateTime(
        notifyDate.year,
        notifyDate.month,
        notifyDate.day,
        event.reminderHour!,
        event.reminderMinute,
      );

      if (notifyAt.isBefore(now)) continue;

      final id = event.id.hashCode ^ (i * 31);
      await _plugin.zonedSchedule(
        id,
        _title(event),
        _body(event),
        tz.TZDateTime.from(notifyAt, tz.local),
        _details(),
        androidScheduleMode: event.reminderType == ReminderType.alarm
            ? AndroidScheduleMode.alarmClock
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      scheduled++;
    }
  }

  // ── Cancel ───────────────────────────────────────────────────────────────────

  /// Cancel all scheduled notifications for the given event id.
  Future<void> cancelForEvent(String eventId) async {
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(eventId.hashCode ^ (i * 31));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Notification title: Telugu name · English name (or just one if same).
  String _title(UserTithiEvent event) {
    if (event.nameTe != null && event.nameTe != event.nameEn) {
      return '${event.nameTe} · ${event.nameEn}';
    }
    return event.nameEn;
  }

  /// Notification body: timing context + notes snippet if available.
  String _body(UserTithiEvent event) {
    final String when;
    switch (event.reminderDaysBefore) {
      case 0:
        when = 'నేడు · Today';
      case 1:
        when = 'రేపు · Tomorrow';
      default:
        when = 'In ${event.reminderDaysBefore} days';
    }

    if (event.notes != null && event.notes!.isNotEmpty) {
      final snippet = event.notes!.length > 80
          ? '${event.notes!.substring(0, 77)}…'
          : event.notes!;
      return '$when · $snippet';
    }
    return when;
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );
}
