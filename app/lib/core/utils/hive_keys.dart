/// All Hive box names and key constants in one place.
/// Never use raw strings for Hive keys — always reference these constants.
class HiveKeys {
  HiveKeys._();

  // Box names
  static const String settingsBox = 'settings';

  // Setting keys
  static const String city = 'city';
  static const String latitude = 'lat';
  static const String longitude = 'lng';
  static const String language = 'language';
  static const String themeMode = 'themeMode';
  static const String timeFormat = 'timeFormat';
}
