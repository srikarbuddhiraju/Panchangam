// Simple two-language string lookup — Telugu and English.
// No arb/intl overhead for two languages.
// Language change triggers Riverpod state update → all widgets rebuild.

enum AppLanguage { telugu, english }

class S {
  S._();

  static AppLanguage _lang = AppLanguage.telugu;

  static AppLanguage get language => _lang;

  static void setLanguage(AppLanguage lang) => _lang = lang;

  static bool get isTelugu => _lang == AppLanguage.telugu;

  // ── Navigation labels ─────────────────────────────────────────────────────
  static String get calendar => isTelugu ? 'పంచాంగం' : 'Calendar';
  static String get eclipse => isTelugu ? 'గ్రహణం' : 'Eclipse';
  static String get premium => isTelugu ? 'ప్రీమియం' : 'Premium';
  static String get settings => isTelugu ? 'సెట్టింగ్స్' : 'Settings';

  // ── Five limbs ────────────────────────────────────────────────────────────
  static String get tithi => isTelugu ? 'తిథి' : 'Tithi';
  static String get vara => isTelugu ? 'వారం' : 'Vara';
  static String get nakshatra => isTelugu ? 'నక్షత్రం' : 'Nakshatra';
  static String get yoga => isTelugu ? 'యోగం' : 'Yoga';
  static String get karana => isTelugu ? 'కరణం' : 'Karana';

  // ── Daily timings ─────────────────────────────────────────────────────────
  static String get sunrise => isTelugu ? 'సూర్యోదయం' : 'Sunrise';
  static String get sunset => isTelugu ? 'సూర్యాస్తమయం' : 'Sunset';
  static String get moonrise => isTelugu ? 'చంద్రోదయం' : 'Moonrise';
  static String get moonset => isTelugu ? 'చంద్రాస్తమయం' : 'Moonset';

  // ── Inauspicious periods ──────────────────────────────────────────────────
  static String get rahuKalam => isTelugu ? 'రాహు కాలం' : 'Rahu Kalam';
  static String get gulikaKalam => isTelugu ? 'గులిక కాలం' : 'Gulika Kalam';
  static String get yamaganda => isTelugu ? 'యమగండ కాలం' : 'Yamaganda';

  // ── Muhurthas ─────────────────────────────────────────────────────────────
  static String get abhijit => isTelugu ? 'అభిజిత్ ముహూర్తం' : 'Abhijit Muhurtha';
  static String get durMuhurta => isTelugu ? 'దుర్ముహూర్తం' : 'Dur Muhurta';
  static String get amritKalam => isTelugu ? 'అమృత కాలం' : 'Amrit Kalam';

  // ── Calendar context ──────────────────────────────────────────────────────
  static String get teluguMonth => isTelugu ? 'తెలుగు మాసం' : 'Telugu Month';
  static String get paksha => isTelugu ? 'పక్షం' : 'Paksha';
  static String get samvatsara => isTelugu ? 'సంవత్సరం' : 'Samvatsara';
  static String get ayanam => isTelugu ? 'అయనం' : 'Ayanam';
  static String get ritu => isTelugu ? 'ఋతువు' : 'Season';
  static String get rashi => isTelugu ? 'రాశి' : 'Rashi';
  static String get shakaYear => isTelugu ? 'శక సంవత్' : 'Shaka Year';

  // ── Paksha names ──────────────────────────────────────────────────────────
  static String get shuklaPaksha => isTelugu ? 'శుక్ల పక్షం' : 'Shukla Paksha';
  static String get krishnaPaksha => isTelugu ? 'కృష్ణ పక్షం' : 'Krishna Paksha';

  // ── Ayanam names ─────────────────────────────────────────────────────────
  static String get uttarayana => isTelugu ? 'ఉత్తరాయణం' : 'Uttarayana';
  static String get dakshinayana => isTelugu ? 'దక్షిణాయనం' : 'Dakshinayana';

  // ── Settings labels ───────────────────────────────────────────────────────
  static String get city => isTelugu ? 'నగరం' : 'City';
  static String get languageLabel => isTelugu ? 'భాష' : 'Language';
  static String get theme => isTelugu ? 'థీమ్' : 'Theme';
  static String get timeFormat => isTelugu ? 'సమయ ఫార్మాట్' : 'Time Format';
  static String get endTime => isTelugu ? 'వరకు' : 'until';

  // ── Week day column headers (short) ───────────────────────────────────────
  static List<String> get weekdayHeaders => isTelugu
      ? ['ఆది', 'సోమ', 'మంగళ', 'బుధ', 'గురు', 'శుక్ర', 'శని']
      : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  // ── Today label ───────────────────────────────────────────────────────────
  static String get today => isTelugu ? 'నేడు' : 'Today';
  static String get notAvailable => isTelugu ? 'లేదు' : 'N/A';
}
