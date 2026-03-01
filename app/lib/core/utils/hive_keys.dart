/// All Hive box names and key constants in one place.
/// Never use raw strings for Hive keys — always reference these constants.
class HiveKeys {
  HiveKeys._();

  // ── Box names ─────────────────────────────────────────────────────────────
  static const String settingsBox = 'settings';
  static const String userEventsBox = 'userEvents';

  // ── Settings keys (in settingsBox) ────────────────────────────────────────
  static const String city = 'city';
  static const String latitude = 'lat';
  static const String longitude = 'lng';
  static const String language = 'language';
  static const String themeMode = 'themeMode';
  static const String timeFormat = 'timeFormat';

  // ── Notification keys (in settingsBox) ───────────────────────────────────
  /// True once we have asked the user for battery-optimisation exemption.
  /// After the first ask we never prompt again (user can change it in Settings).
  static const String batteryOptAsked = 'batteryOptAsked';

  // ── Premium key (in settingsBox) ──────────────────────────────────────────
  /// Stored as bool. Default: false.
  /// Set to true on purchase confirmation (billing deferred — debug toggle only for now).
  static const String isPremium = 'isPremium';
}
