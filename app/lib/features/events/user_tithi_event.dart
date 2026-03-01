/// Whether the user wants a soft reminder or a hard alarm.
enum ReminderType { reminder, alarm }

/// A user-created tithi-based personal event.
///
/// Examples: "Ramana Maharshi Jayanti", "Amma's Birthday", "Pitru Tarpana".
///
/// Stored in Hive box [HiveKeys.userEventsBox] as JSON strings.
/// Key = event [id] (UUID).
class UserTithiEvent {
  /// RFC 4122 UUID — stable across edits, cloud-sync-ready.
  final String id;

  /// Display name in English (required).
  final String nameEn;

  /// Display name in Telugu (optional).
  final String? nameTe;

  /// Tithi number 1–30, matching [Tithi.number()] output directly.
  ///
  /// 1–15 = Shukla Pratipada … Purnima
  /// 16–30 = Krishna Pratipada … Amavasya
  final int tithi;

  /// If non-null, this event recurs once a year in this Telugu month (1–12).
  /// If null, the event recurs every paksha (twice a month).
  final int? teluguMonth;

  /// Hour (0–23) at which the reminder notification fires.
  /// null = no reminder set.
  final int? reminderHour;

  /// Minute (0–59) for the reminder time. Meaningful only when [reminderHour] is set.
  final int reminderMinute;

  /// How many days before the tithi day the reminder fires (0 = same day).
  final int reminderDaysBefore;

  /// Whether to fire a soft notification or a hard alarm.
  final ReminderType reminderType;

  /// Optional free-text note shown on the event card.
  final String? notes;

  /// Whether this event is currently active.
  /// Inactive events are stored but not shown on the calendar or Today screen.
  final bool isActive;

  /// Hex color string for the calendar dot (e.g. '#FFD700' for gold).
  final String color;

  const UserTithiEvent({
    required this.id,
    required this.nameEn,
    this.nameTe,
    required this.tithi,
    this.teluguMonth,
    this.reminderHour,
    this.reminderMinute = 0,
    this.reminderDaysBefore = 0,
    this.reminderType = ReminderType.reminder,
    this.notes,
    this.isActive = true,
    this.color = '#FFD700',
  })  : assert(tithi >= 1 && tithi <= 30, 'tithi must be 1–30'),
        assert(
          teluguMonth == null || (teluguMonth >= 1 && teluguMonth <= 12),
          'teluguMonth must be 1–12 or null',
        );

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameEn': nameEn,
        if (nameTe != null) 'nameTe': nameTe,
        'tithi': tithi,
        if (teluguMonth != null) 'teluguMonth': teluguMonth,
        if (reminderHour != null) 'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'reminderDaysBefore': reminderDaysBefore,
        'reminderType': reminderType.name,
        if (notes != null) 'notes': notes,
        'isActive': isActive,
        'color': color,
      };

  factory UserTithiEvent.fromMap(Map<String, dynamic> m) => UserTithiEvent(
        id: m['id'] as String,
        nameEn: m['nameEn'] as String,
        nameTe: m['nameTe'] as String?,
        tithi: m['tithi'] as int,
        teluguMonth: m['teluguMonth'] as int?,
        // reminderHour/Minute/DaysBefore replace the old reminderMinutes field.
        // Old events with only reminderMinutes will load with no reminder set.
        reminderHour: m['reminderHour'] as int?,
        reminderMinute: (m['reminderMinute'] as int?) ?? 0,
        reminderDaysBefore: (m['reminderDaysBefore'] as int?) ?? 0,
        reminderType: ReminderType.values.firstWhere(
          (e) => e.name == (m['reminderType'] as String?),
          orElse: () => ReminderType.reminder,
        ),
        notes: m['notes'] as String?,
        isActive: (m['isActive'] as bool?) ?? true,
        color: (m['color'] as String?) ?? '#FFD700',
      );

  UserTithiEvent copyWith({
    String? nameEn,
    String? nameTe,
    int? tithi,
    Object? teluguMonth = _sentinel,
    Object? reminderHour = _sentinel,
    int? reminderMinute,
    int? reminderDaysBefore,
    ReminderType? reminderType,
    Object? notes = _sentinel,
    bool? isActive,
    String? color,
  }) =>
      UserTithiEvent(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameTe: nameTe ?? this.nameTe,
        tithi: tithi ?? this.tithi,
        teluguMonth:
            teluguMonth == _sentinel ? this.teluguMonth : teluguMonth as int?,
        reminderHour:
            reminderHour == _sentinel ? this.reminderHour : reminderHour as int?,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
        reminderType: reminderType ?? this.reminderType,
        notes: notes == _sentinel ? this.notes : notes as String?,
        isActive: isActive ?? this.isActive,
        color: color ?? this.color,
      );
}

// Sentinel for nullable copyWith params (distinguishes "not provided" from explicit null).
const Object _sentinel = Object();
