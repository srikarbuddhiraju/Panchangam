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

  /// Minutes before the tithi to send a reminder notification.
  /// null = no reminder.
  ///
  /// TODO(Session4): schedule via NotificationService when non-null.
  final int? reminderMinutes;

  /// Whether this event is currently active.
  /// Inactive events are stored but not shown on the calendar or Today screen.
  final bool isActive;

  /// Hex color string for the calendar dot (e.g. '#FFD700' for gold).
  /// Defaults to kGold.
  final String color;

  const UserTithiEvent({
    required this.id,
    required this.nameEn,
    this.nameTe,
    required this.tithi,
    this.teluguMonth,
    this.reminderMinutes,
    this.isActive = true,
    this.color = '#FFD700',
  }) : assert(tithi >= 1 && tithi <= 30, 'tithi must be 1–30'),
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
        if (reminderMinutes != null) 'reminderMinutes': reminderMinutes,
        'isActive': isActive,
        'color': color,
      };

  factory UserTithiEvent.fromMap(Map<String, dynamic> m) => UserTithiEvent(
        id: m['id'] as String,
        nameEn: m['nameEn'] as String,
        nameTe: m['nameTe'] as String?,
        tithi: m['tithi'] as int,
        teluguMonth: m['teluguMonth'] as int?,
        reminderMinutes: m['reminderMinutes'] as int?,
        isActive: (m['isActive'] as bool?) ?? true,
        color: (m['color'] as String?) ?? '#FFD700',
      );

  UserTithiEvent copyWith({
    String? nameEn,
    String? nameTe,
    int? tithi,
    Object? teluguMonth = _sentinel,
    Object? reminderMinutes = _sentinel,
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
        reminderMinutes: reminderMinutes == _sentinel
            ? this.reminderMinutes
            : reminderMinutes as int?,
        isActive: isActive ?? this.isActive,
        color: color ?? this.color,
      );
}

// Sentinel for nullable copyWith params (distinguishes "not provided" from explicit null).
const Object _sentinel = Object();
