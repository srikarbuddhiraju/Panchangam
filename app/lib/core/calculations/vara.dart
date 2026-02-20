/// Vara (weekday) calculations.
///
/// The Vara is the day of the week, starting at sunrise (not midnight).
/// vara = (JD + 1.5) mod 7, giving 0=Sunday, 1=Monday, ..., 6=Saturday
class Vara {
  Vara._();

  static const List<String> namesTe = [
    'ఆదివారం',    // Sunday
    'సోమవారం',   // Monday
    'మంగళవారం',  // Tuesday
    'బుధవారం',   // Wednesday
    'గురువారం',  // Thursday
    'శుక్రవారం', // Friday
    'శనివారం',   // Saturday
  ];

  static const List<String> namesEn = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  static const List<String> rulingPlanets = [
    'Surya (Sun)', 'Chandra (Moon)', 'Mangala (Mars)',
    'Budha (Mercury)', 'Guru (Jupiter)',
    'Shukra (Venus)', 'Shani (Saturn)',
  ];

  static const List<String> rulingPlanetsTe = [
    'సూర్యుడు', 'చంద్రుడు', 'అంగారకుడు',
    'బుధుడు', 'బృహస్పతి',
    'శుక్రుడు', 'శని',
  ];

  /// Vara number (0–6) from a Julian Day Number.
  /// Works at any time of day — use sunrise JD for the "Panchangam vara".
  static int number(double jd) {
    // (JD + 1.5) mod 7; JD 0 was a Monday
    return ((jd + 1.5) % 7).floor();
  }

  /// Vara number from a Dart DateTime (uses the date's day of week).
  static int fromDateTime(DateTime dt) {
    // DateTime.weekday: 1=Monday ... 7=Sunday
    // We want 0=Sunday
    return dt.weekday % 7;
  }
}
