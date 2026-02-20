import 'solar_position.dart';

/// Telugu calendar context calculations.
///
/// Covers: Telugu month, Samvatsara (60-year cycle), Paksha,
/// Ayanam (Uttarayana/Dakshinayana), Ritu (season), and Shaka year.
class TeluguCalendar {
  TeluguCalendar._();

  // ── Telugu months (Amavasyant system — month ends on Amavasya) ────────────
  static const List<String> monthNamesTe = [
    'చైత్రం', 'వైశాఖం', 'జ్యేష్ఠం', 'ఆషాఢం',
    'శ్రావణం', 'భాద్రపదం', 'ఆశ్వయుజం', 'కార్తీకం',
    'మార్గశిరం', 'పుష్యం', 'మాఘం', 'ఫాల్గుణం',
  ];

  static const List<String> monthNamesEn = [
    'Chaitra', 'Vaisakha', 'Jyeshtha', 'Ashadha',
    'Shravana', 'Bhadrapada', 'Ashvayuja', 'Kartika',
    'Margashira', 'Pushya', 'Magha', 'Phalguna',
  ];

  // ── 60-year Samvatsara cycle ──────────────────────────────────────────────
  static const List<String> samvatsarasTe = [
    'ప్రభవ', 'విభవ', 'శుక్ల', 'ప్రమోద', 'ప్రజాపతి',
    'అంగిరస', 'శ్రీముఖ', 'భావ', 'యువ', 'ధాత',
    'ఈశ్వర', 'బహుధాన్య', 'ప్రమాధి', 'విక్రమ', 'వృష',
    'చిత్రభాను', 'సుభాను', 'తారణ', 'పార్థివ', 'వ్యయ',
    'సర్వజిత్', 'సర్వధారి', 'విరోధి', 'విక్రుతి', 'ఖర',
    'నందన', 'విజయ', 'జయ', 'మన్మథ', 'దుర్ముఖి',
    'హేవిళంబి', 'విళంబి', 'వికారి', 'శార్వరి', 'ప్లవ',
    'శుభకృత్', 'శోభకృత్', 'క్రోధి', 'విశ్వవసు', 'పరాభవ',
    'ప్లవంగ', 'కీలక', 'సౌమ్య', 'సాధారణ', 'విరోధకృత్',
    'పరిధావి', 'ప్రమాదీచ', 'ఆనంద', 'రాక్షస', 'నళ',
    'పింగళ', 'కాళయుక్తి', 'సిద్ధార్థి', 'రౌద్ర', 'దుర్మతి',
    'దుందుభి', 'రుధిరోద్గారి', 'రక్తాక్షి', 'క్రోధన', 'అక్షయ',
  ];

  static const List<String> samvatsarasEn = [
    'Prabhava', 'Vibhava', 'Shukla', 'Pramoda', 'Prajapati',
    'Angirasa', 'Shrimukha', 'Bhava', 'Yuva', 'Dhata',
    'Ishvara', 'Bahudhanya', 'Pramadhi', 'Vikrama', 'Vrisha',
    'Chitrabhanu', 'Subhanu', 'Tarana', 'Parthiva', 'Vyaya',
    'Sarvajit', 'Sarvadhari', 'Virodhi', 'Vikruti', 'Khara',
    'Nandana', 'Vijaya', 'Jaya', 'Manmatha', 'Durmukhi',
    'Hevilambi', 'Vilambi', 'Vikari', 'Sharvari', 'Plava',
    'Shubhakrut', 'Shobhakrut', 'Krodhi', 'Vishvavasu', 'Parabhava',
    'Plavanga', 'Kilaka', 'Saumya', 'Sadharana', 'Virodhakrut',
    'Paridhavi', 'Pramadicha', 'Ananda', 'Rakshasa', 'Nala',
    'Pingala', 'Kalayukti', 'Siddharthi', 'Raudra', 'Durmati',
    'Dundubhi', 'Rudhirodgari', 'Raktakshi', 'Krodhana', 'Akshaya',
  ];

  // ── Ritu (seasons) ────────────────────────────────────────────────────────
  static const List<String> rituNamesTe = [
    'వసంత', 'గ్రీష్మ', 'వర్ష', 'శరత్', 'హేమంత', 'శిశిర',
  ];
  static const List<String> rituNamesEn = [
    'Vasanta (Spring)', 'Grishma (Summer)', 'Varsha (Monsoon)',
    'Sharad (Autumn)', 'Hemanta (Pre-Winter)', 'Shishira (Winter)',
  ];

  /// Compute the Telugu month number (1–12) for a given JD.
  ///
  /// Telugu month follows the Amavasyant system (month = from the Amavasya
  /// to the next Amavasya). The month is determined by Sun's sidereal longitude
  /// at the time of Amavasya.
  ///
  /// Simplified approach: Use Sun's sidereal longitude to determine the
  /// approximate solar month, then adjust by about 1 month.
  static int monthNumber(double jd) {
    // Sun's sidereal longitude determines the solar month (0-11)
    final double sunLon = SolarPosition.siderealLongitude(jd);
    // Solar month: 0=Mesha (Aries), ..., 11=Meena (Pisces)
    final int solarMonth = (sunLon / 30.0).floor();

    // Telugu lunar month lags by ~1 month behind the solar month
    // Chaitra (1) corresponds to Sun in Mesha (Aries)
    // Approximate: lunar month ≈ solarMonth (adjusted)
    // The exact calculation requires knowing the current Amavasya position

    // This simplified mapping gives a good-enough approximation for display.
    // Exact calculation would require finding the current Amavasya anchor point.
    final int lunarMonth = ((solarMonth + 1) % 12) + 1; // 1-indexed
    return lunarMonth;
  }

  /// Compute Samvatsara for a given year of the Telugu calendar.
  ///
  /// The 60-year cycle started at Kali Yuga. The cycle index:
  /// index = (shakaYear - 1) mod 60  (approximately)
  ///
  /// Vijaya = index 26 (2024-25 CE)
  /// Jaya   = index 27 (2025-26 CE)
  /// Manmatha = index 28 (2026-27 CE)
  static String samvatsaraTe(int shakaYear) {
    // Calibration: Shaka 1946 (2024-25 CE) = Vijaya = index 26
    final int index = ((shakaYear - 1946 + 26) % 60 + 60) % 60;
    return samvatsarasTe[index];
  }

  static String samvatsaraEn(int shakaYear) {
    final int index = ((shakaYear - 1946 + 26) % 60 + 60) % 60;
    return samvatsarasEn[index];
  }

  /// Shaka year for a given Gregorian date.
  static int shakaYear(DateTime date) {
    if (date.month > 3 || (date.month == 3 && date.day >= 22)) {
      return date.year - 78;
    }
    return date.year - 79;
  }

  /// Ayanam (Uttarayana / Dakshinayana) based on Sun's sidereal longitude.
  ///
  /// Uttarayana: Sun in Capricorn–Gemini (lon 270° to 90°, i.e., < 90 or > 270)
  /// Dakshinayana: Sun in Cancer–Sagittarius (lon 90° to 270°)
  static String ayanamEn(double jd) {
    final double sunLon = SolarPosition.siderealLongitude(jd);
    return (sunLon >= 270.0 || sunLon < 90.0) ? 'Uttarayana' : 'Dakshinayana';
  }

  static String ayanamTe(double jd) {
    final double sunLon = SolarPosition.siderealLongitude(jd);
    return (sunLon >= 270.0 || sunLon < 90.0) ? 'ఉత్తరాయణం' : 'దక్షిణాయనం';
  }

  /// Ritu (season) number (1–6) from Moon's sidereal longitude position in the year.
  /// Derived from Telugu month: months 1-2 = Vasanta, 3-4 = Grishma, etc.
  static int rituNumber(int teluguMonthNumber) {
    return ((teluguMonthNumber - 1) ~/ 2) + 1;
  }
}
