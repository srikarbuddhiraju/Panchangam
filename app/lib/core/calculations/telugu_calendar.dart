import 'julian_day.dart';
import 'solar_position.dart';
import 'tithi.dart';

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

  // ── Amavasyant month calculation ─────────────────────────────────────────
  //
  // The Telugu (Amavasyant) month is named after the solar rashi in which the
  // month-ending Amavasya falls.  The table is:
  //   Amavasya in Mesha(0)     → Chaitra(1)
  //   Amavasya in Vrishabha(1) → Vaisakha(2)
  //   ... (rashi index + 1)
  //   Amavasya in Meena(11)    → Phalguna(12)
  //
  // Adhika (leap) month: when two consecutive Amavasyas fall in the same rashi,
  // the first ending month is Adhika (extra) and the second is Nija (regular).

  /// Find the Julian Day of the new moon (exact conjunction, end of tithi 30).
  ///
  /// Scans in 0.4-day steps to locate any Amavasya period, then refines
  /// to the precise new moon moment using the existing Tithi.endTime binary
  /// search.  This gives a consistent reference independent of scan offset,
  /// which matters when the new moon falls near a rashi boundary.
  ///
  /// [forward] = true  → next new moon at or after jd.
  /// [forward] = false → previous new moon before jd.
  static double _findAmavasyaJd(double jd, {required bool forward}) {
    final int dir = forward ? 1 : -1;
    double d = jd;

    // If already in Amavasya (tithi 30):
    //   forward  → refine to the new moon moment of this Amavasya
    //   backward → skip past it so we find the previous one
    if (Tithi.number(d) == 30) {
      if (forward) {
        return JulianDay.fromIST(Tithi.endTime(d));
      }
      d -= 2.5;
    }

    for (int i = 0; i < 80; i++) {
      d += dir * 0.4;
      if (Tithi.number(d) == 30) {
        // Refine to the exact new moon moment (end of Amavasya)
        return JulianDay.fromIST(Tithi.endTime(d));
      }
    }

    return jd; // fallback — should never happen for valid input
  }

  /// Compute the Telugu month number (1–12) for a given JD.
  ///
  /// Correct Amavasyant method: find the NEXT Amavasya and read the Sun's
  /// sidereal rashi at that point.  Accurate for any date in the month,
  /// including dates near Sankranti crossings where a solar approximation
  /// would be off by one month.
  static int monthNumber(double jd) {
    final double nextAm = _findAmavasyaJd(jd, forward: true);
    final int rashi =
        (SolarPosition.siderealLongitude(nextAm) / 30.0).floor();
    return rashi + 1; // 1-indexed: Mesha(0)→1, ..., Meena(11)→12
  }

  /// Returns true if the date falls in an Adhika (leap) lunar month.
  ///
  /// Traditional rule: a lunar month is Adhika when the sun does NOT change
  /// rashi during that month — i.e., the month begins and ends in the same
  /// solar rashi (no Sankranti inside).  Equivalently, the Amavasya that
  /// STARTED this month and the Amavasya that ENDS it both have the sun in
  /// the same rashi.
  ///
  /// Implementation: check the PREVIOUS Amavasya (prevAm) and the NEXT
  /// Amavasya (nextAm) around the given date.  If they are in the same
  /// rashi, the current month (prevAm → nextAm) is Adhika.
  ///
  /// Note: some sources use "next two Amavasyas same rashi → first period is
  /// Adhika" — that rule marks the WRONG month (one lunation too early).
  static bool isAdhikaMaasa(double jd) {
    final double nextAm = _findAmavasyaJd(jd, forward: true);
    final double prevAm = _findAmavasyaJd(jd, forward: false);
    final int rashi1 =
        (SolarPosition.siderealLongitude(prevAm) / 30.0).floor();
    final int rashi2 =
        (SolarPosition.siderealLongitude(nextAm) / 30.0).floor();
    return rashi1 == rashi2;
  }

  /// Compute Samvatsara for a given year of the Telugu calendar.
  ///
  /// The 60-year cycle index:
  /// Visvavasu = index 38 (Shaka 1947 = 2025-26 CE) — confirmed via drikpanchang.com
  /// Parabhava = index 39 (Shaka 1948 = 2026-27 CE)
  static String samvatsaraTe(int shakaYear) {
    // Calibration: Shaka 1947 (2025-26 CE) = Visvavasu = index 38
    final int index = ((shakaYear - 1947 + 38) % 60 + 60) % 60;
    return samvatsarasTe[index];
  }

  static String samvatsaraEn(int shakaYear) {
    final int index = ((shakaYear - 1947 + 38) % 60 + 60) % 60;
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
