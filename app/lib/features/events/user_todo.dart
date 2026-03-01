import 'user_tithi_event.dart' show ReminderType;

/// A one-time, tithi-based task for Pro users.
///
/// Unlike [UserTithiEvent] (which recurs), a To-Do is pinned to the NEXT
/// occurrence of the chosen tithi at the time of creation ([targetDate]).
/// Once that date passes or the user marks it complete, the To-Do is archived.
///
/// Stored in Hive box [HiveKeys.userTodosBox] as JSON strings.
/// Key = todo [id] (UUID).
class UserTodo {
  /// RFC 4122 UUID — stable across edits.
  final String id;

  /// Display title (required).
  final String title;

  /// Optional free-text note shown on the card.
  final String? notes;

  /// Tithi number 1–30, same encoding as [UserTithiEvent.tithi].
  final int tithi;

  /// If non-null, the tithi is matched only in this Telugu month (1–12).
  /// If null, the first occurrence in any paksha is used.
  final int? teluguMonth;

  /// The computed date this To-Do is pinned to (set at creation time).
  final DateTime targetDate;

  /// Whether the user has marked this To-Do as done.
  final bool isCompleted;

  /// Soft delete flag. false = deleted (filtered out of the list).
  final bool isActive;

  /// Hour (0–23) at which the reminder fires on [targetDate].
  /// null = no reminder.
  final int? reminderHour;

  /// Minute (0–59) for the reminder. Meaningful only when [reminderHour] is set.
  final int reminderMinute;

  /// Whether to use a soft notification or a hard alarm.
  final ReminderType reminderType;

  const UserTodo({
    required this.id,
    required this.title,
    this.notes,
    required this.tithi,
    this.teluguMonth,
    required this.targetDate,
    this.isCompleted = false,
    this.isActive = true,
    this.reminderHour,
    this.reminderMinute = 0,
    this.reminderType = ReminderType.reminder,
  })  : assert(tithi >= 1 && tithi <= 30, 'tithi must be 1–30'),
        assert(
          teluguMonth == null || (teluguMonth >= 1 && teluguMonth <= 12),
          'teluguMonth must be 1–12 or null',
        );

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        if (notes != null) 'notes': notes,
        'tithi': tithi,
        if (teluguMonth != null) 'teluguMonth': teluguMonth,
        'targetDate': targetDate.toIso8601String(),
        'isCompleted': isCompleted,
        'isActive': isActive,
        if (reminderHour != null) 'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'reminderType': reminderType.name,
      };

  factory UserTodo.fromMap(Map<String, dynamic> m) => UserTodo(
        id: m['id'] as String,
        title: m['title'] as String,
        notes: m['notes'] as String?,
        tithi: m['tithi'] as int,
        teluguMonth: m['teluguMonth'] as int?,
        targetDate: DateTime.parse(m['targetDate'] as String),
        isCompleted: (m['isCompleted'] as bool?) ?? false,
        isActive: (m['isActive'] as bool?) ?? true,
        reminderHour: m['reminderHour'] as int?,
        reminderMinute: (m['reminderMinute'] as int?) ?? 0,
        reminderType: ReminderType.values.firstWhere(
          (e) => e.name == (m['reminderType'] as String?),
          orElse: () => ReminderType.reminder,
        ),
      );

  UserTodo copyWith({
    String? title,
    Object? notes = _sentinel,
    int? tithi,
    Object? teluguMonth = _sentinel,
    DateTime? targetDate,
    bool? isCompleted,
    bool? isActive,
    Object? reminderHour = _sentinel,
    int? reminderMinute,
    ReminderType? reminderType,
  }) =>
      UserTodo(
        id: id,
        title: title ?? this.title,
        notes: notes == _sentinel ? this.notes : notes as String?,
        tithi: tithi ?? this.tithi,
        teluguMonth:
            teluguMonth == _sentinel ? this.teluguMonth : teluguMonth as int?,
        targetDate: targetDate ?? this.targetDate,
        isCompleted: isCompleted ?? this.isCompleted,
        isActive: isActive ?? this.isActive,
        reminderHour:
            reminderHour == _sentinel ? this.reminderHour : reminderHour as int?,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        reminderType: reminderType ?? this.reminderType,
      );
}

const Object _sentinel = Object();
