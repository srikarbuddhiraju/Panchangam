import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/events/user_tithi_event.dart'
    show UserTithiEvent, ReminderType;

/// Handles scheduling and cancelling local notifications for personal tithi events.
///
/// Call [init] once in main() — initialises timezone + plugin only.
/// Do NOT request permissions in init(): no Activity exists before runApp().
/// Call [requestPermissions] from a post-frame callback after runApp() instead.
///
/// Notification ID formula: `event.id.hashCode ^ (occurrenceIndex * 31)`
/// Up to 3 future occurrences are scheduled per event.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _systemChannel = MethodChannel('panchangam/system');

  static const _channelId = 'panchangam_events';
  static const _channelName = 'Personal Events';
  static const _channelDesc = 'Reminders for your personal tithi events';

  static const _alarmChannelId = 'panchangam_alarms';
  static const _alarmChannelName = 'Personal Alarms';
  static const _alarmChannelDesc = 'Alarms for your personal tithi events';

  // ── Init ────────────────────────────────────────────────────────────────────

  /// Initialise timezone and the plugin. No permission requests here.
  Future<void> init() async {
    // IST is the only timezone needed — India-only app.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Request POST_NOTIFICATIONS (Android 13+) and, if [askBatteryOpt] is true,
  /// battery-optimization exemption. Must be called with an active Activity.
  ///
  /// [askBatteryOpt] should be false after the first ever prompt — the system
  /// dialog is annoying if it reappears on every launch.
  Future<void> requestPermissions({bool askBatteryOpt = true}) async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    if (!askBatteryOpt) return;

    // Request battery-optimization exemption via MainActivity MethodChannel.
    // Inexact reminders can be heavily deferred on Samsung/MIUI without this.
    try {
      final exempt = await _systemChannel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          true;
      if (!exempt) {
        await _systemChannel
            .invokeMethod('requestIgnoreBatteryOptimizations');
      }
    } catch (_) {
      // Channel unavailable in tests / non-Android — ignore.
    }
  }

  /// True if the app is allowed to post notifications (POST_NOTIFICATIONS granted).
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.areNotificationsEnabled() ?? true;
  }

  /// Fire an immediate visible notification to verify the channel + permission.
  /// Use from a "Test notification" button in Settings.
  Future<void> showTestNotification(bool isTelugu) async {
    await _plugin.show(
      0xDEAD,
      isTelugu ? 'పరీక్ష నోటిఫికేషన్' : 'Test Notification',
      isTelugu
          ? 'Panchangam నోటిఫికేషన్లు పని చేస్తున్నాయి!'
          : 'Panchangam notifications are working!',
      _details(),
    );
  }

  /// Schedule a notification via [zonedSchedule] for 1 minute from now.
  ///
  /// Use from Settings to verify that scheduled (non-immediate) notifications
  /// work on this device. If this fires after ~1 minute, scheduling works fine
  /// and the real reminders are simply waiting for their tithi date.
  Future<void> scheduleMinuteTestNotification(bool isTelugu) async {
    final notifyAt = DateTime.now().add(const Duration(minutes: 1));
    await _plugin.zonedSchedule(
      0xBEEF,
      isTelugu ? 'షెడ్యూల్ పరీక్ష' : 'Scheduled Test',
      isTelugu
          ? '1 నిమిషం ముందు సెట్ చేయబడింది — షెడ్యూలింగ్ పని చేస్తోంది!'
          : 'Scheduled 1 minute ago — scheduling is working!',
      tz.TZDateTime.from(notifyAt, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// True if exact-alarm scheduling is permitted on this device.
  ///
  /// Always true on Android < 12. On Android 12+, the user must grant
  /// SCHEDULE_EXACT_ALARM in Settings → Apps → Special app access →
  /// Alarms & reminders.
  Future<bool> canScheduleExactNotifications() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.canScheduleExactNotifications() ?? true;
  }

  /// Opens the system page where the user grants SCHEDULE_EXACT_ALARM.
  Future<void> openAlarmSettings() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // ── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedule up to [maxOccurrences] notifications for [event].
  ///
  /// Each notification fires at [event.reminderHour]:[event.reminderMinute]
  /// on the day that is [event.reminderDaysBefore] days before the tithi date.
  /// Occurrences already in the past are skipped silently.
  ///
  /// [ReminderType.alarm] uses AndroidScheduleMode.alarmClock (exact, shown in
  /// system clock). Requires SCHEDULE_EXACT_ALARM — automatically falls back
  /// to inexact if the permission has not been granted yet.
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

    // Alarm mode requires SCHEDULE_EXACT_ALARM. Fall back gracefully instead
    // of crashing silently if the permission hasn't been granted yet.
    final AndroidScheduleMode scheduleMode;
    if (event.reminderType == ReminderType.alarm) {
      final canExact = await canScheduleExactNotifications();
      scheduleMode =
          canExact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexact;
    } else {
      scheduleMode = AndroidScheduleMode.inexact;
    }

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
        event.reminderType == ReminderType.alarm ? _alarmDetails() : _details(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      scheduled++;
    }
  }

  // ── To-Do notifications ──────────────────────────────────────────────────────

  /// Schedule a single notification for a To-Do on [targetDate] at
  /// [reminderHour]:[reminderMinute]. No-op if already in the past.
  ///
  /// Uses the alarm channel (and alarmClock mode) when [isAlarm] is true.
  Future<void> scheduleForTodo({
    required String id,
    required String title,
    String? body,
    required DateTime targetDate,
    required int reminderHour,
    required int reminderMinute,
    required bool isAlarm,
  }) async {
    final notifyAt = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      reminderHour,
      reminderMinute,
    );
    if (notifyAt.isBefore(DateTime.now())) return;

    final AndroidScheduleMode mode;
    if (isAlarm) {
      final canExact = await canScheduleExactNotifications();
      mode =
          canExact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexact;
    } else {
      mode = AndroidScheduleMode.inexact;
    }

    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body ?? (isAlarm ? '⏰ నేడు · Today' : '🔔 నేడు · Today'),
      tz.TZDateTime.from(notifyAt, tz.local),
      isAlarm ? _alarmDetails() : _details(),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel the scheduled notification for the given To-Do id.
  Future<void> cancelForTodo(String todoId) async {
    await _plugin.cancel(todoId.hashCode);
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

  NotificationDetails _alarmDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: _alarmChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          sound: UriAndroidNotificationSound(
            'content://settings/system/alarm_alert',
          ),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
        ),
      );
}
