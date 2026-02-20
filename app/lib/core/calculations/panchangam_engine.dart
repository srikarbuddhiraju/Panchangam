import 'julian_day.dart';
import 'tithi.dart';
import 'nakshatra.dart';
import 'yoga.dart';
import 'karana.dart';
import 'vara.dart';
import 'rashi.dart';
import 'sunrise_sunset.dart';
import 'moonrise_moonset.dart';
import 'kalam_timings.dart';
import 'muhurtha.dart';
import 'telugu_calendar.dart';

/// The main computation entry point.
///
/// Call [PanchangamEngine.compute] to get all Panchangam data for a date + city.
/// All DateTime fields in [PanchangamData] are in IST (UTC+5:30).
class PanchangamEngine {
  PanchangamEngine._();

  /// Compute complete Panchangam data for a given date and location.
  ///
  /// [date] — the Gregorian calendar date (only year/month/day used)
  /// [lat]  — latitude in degrees (north positive)
  /// [lng]  — longitude in degrees (east positive)
  static PanchangamData compute({
    required DateTime date,
    required double lat,
    required double lng,
  }) {
    // ── Sunrise & Sunset ──────────────────────────────────────────────────
    final List<DateTime> sunTimes =
        SunriseSunset.computeNOAA(date, lat, lng);
    final DateTime sunrise = sunTimes[0];
    final DateTime sunset = sunTimes[1];

    // JD at sunrise (the reference point for all five limbs in Panchangam)
    final double jdSunrise = JulianDay.fromIST(sunrise);

    // ── Five Limbs ────────────────────────────────────────────────────────

    // 1. Tithi
    final int tithiNum = Tithi.number(jdSunrise);
    final DateTime tithiEnd = Tithi.endTime(jdSunrise);

    // 2. Vara (weekday)
    final int varaNum = Vara.number(jdSunrise);

    // 3. Nakshatra
    final int nakshatraNum = Nakshatra.number(jdSunrise);
    final DateTime nakshatraEnd = Nakshatra.endTime(jdSunrise);

    // 4. Yoga
    final int yogaNum = Yoga.number(jdSunrise);
    final DateTime yogaEnd = Yoga.endTime(jdSunrise);

    // 5. Karana
    final int karanaNum = Karana.number(jdSunrise);
    final DateTime karanaEnd = Karana.endTime(jdSunrise);

    // ── Moonrise & Moonset ────────────────────────────────────────────────
    final List<DateTime?> moonTimes = MoonriseMoonset.compute(date, lat, lng);
    final DateTime? moonrise = moonTimes[0];
    final DateTime? moonset = moonTimes[1];

    // ── Kalam Timings ─────────────────────────────────────────────────────
    final List<DateTime> rahu = KalamTimings.rahuKalam(varaNum, sunrise, sunset);
    final List<DateTime> gulika =
        KalamTimings.gulikaKalam(varaNum, sunrise, sunset);
    final List<DateTime> yama = KalamTimings.yamaganda(varaNum, sunrise, sunset);

    // ── Muhurthas ─────────────────────────────────────────────────────────
    final List<DateTime>? abhijitTimes =
        Muhurtha.abhijit(varaNum, sunrise, sunset);
    final List<List<DateTime>> durTimes =
        Muhurtha.durMuhurta(varaNum, sunrise, sunset);
    final List<DateTime> amritTimes =
        Muhurtha.amritKalam(nakshatraNum, sunrise, sunset);

    // ── Calendar Context ──────────────────────────────────────────────────
    final int rashiNum = Rashi.number(jdSunrise);
    final int shakaYr = TeluguCalendar.shakaYear(date);
    final int teluguMonthNum = TeluguCalendar.monthNumber(jdSunrise);
    final int rituNum = TeluguCalendar.rituNumber(teluguMonthNum);

    // ── Assemble & return ─────────────────────────────────────────────────
    return PanchangamData(
      date: DateTime(date.year, date.month, date.day),
      lat: lat,
      lng: lng,

      // Tithi
      tithiNumber: tithiNum,
      tithiNameTe: Tithi.namesTe[tithiNum - 1],
      tithiNameEn: Tithi.namesEn[tithiNum - 1],
      tithiEndTime: tithiEnd,
      paksha: Tithi.paksha(tithiNum),
      pakshaTe: Tithi.pakshaTe(tithiNum),

      // Vara
      varaNumber: varaNum,
      varaNameTe: Vara.namesTe[varaNum],
      varaNameEn: Vara.namesEn[varaNum],

      // Nakshatra
      nakshatraNumber: nakshatraNum,
      nakshatraNameTe: Nakshatra.namesTe[nakshatraNum - 1],
      nakshatraNameEn: Nakshatra.namesEn[nakshatraNum - 1],
      nakshatraEndTime: nakshatraEnd,

      // Yoga
      yogaNumber: yogaNum,
      yogaNameTe: Yoga.namesTe[yogaNum - 1],
      yogaNameEn: Yoga.namesEn[yogaNum - 1],
      yogaEndTime: yogaEnd,

      // Karana
      karanaNumber: karanaNum,
      karanaNameTe: Karana.nameTe(karanaNum),
      karanaNameEn: Karana.nameEn(karanaNum),
      karanaEndTime: karanaEnd,

      // Timings
      sunrise: sunrise,
      sunset: sunset,
      moonrise: moonrise,
      moonset: moonset,

      // Kalam
      rahuKalamStart: rahu[0],
      rahuKalamEnd: rahu[1],
      gulikaKalamStart: gulika[0],
      gulikaKalamEnd: gulika[1],
      yamagandaStart: yama[0],
      yamagandaEnd: yama[1],

      // Muhurthas
      abhijitStart: abhijitTimes?[0],
      abhijitEnd: abhijitTimes?[1],
      abhijitValid: abhijitTimes != null,
      durMuhurtaStart: durTimes[0][0],
      durMuhurtaEnd: durTimes[0][1],
      amritKalamStart: amritTimes[0],
      amritKalamEnd: amritTimes[1],

      // Calendar context
      teluguMonthTe: TeluguCalendar.monthNamesTe[teluguMonthNum - 1],
      teluguMonthEn: TeluguCalendar.monthNamesEn[teluguMonthNum - 1],
      teluguMonthNumber: teluguMonthNum,
      samvatsaraTe: TeluguCalendar.samvatsaraTe(shakaYr),
      samvatsaraEn: TeluguCalendar.samvatsaraEn(shakaYr),
      ayanamTe: TeluguCalendar.ayanamTe(jdSunrise),
      ayanamEn: TeluguCalendar.ayanamEn(jdSunrise),
      rituTe: TeluguCalendar.rituNamesTe[rituNum - 1],
      rituEn: TeluguCalendar.rituNamesEn[rituNum - 1],
      rashiNumber: rashiNum,
      rashiNameTe: Rashi.namesTe[rashiNum - 1],
      rashiNameEn: Rashi.namesEn[rashiNum - 1],
      shakaYear: shakaYr,
    );
  }
}

/// Immutable data class holding all computed Panchangam data for one day.
class PanchangamData {
  // ── Metadata ──────────────────────────────────────────────────────────────
  final DateTime date;
  final double lat;
  final double lng;

  // ── Five Limbs ────────────────────────────────────────────────────────────
  final int tithiNumber;
  final String tithiNameTe;
  final String tithiNameEn;
  final DateTime tithiEndTime;
  final String paksha;
  final String pakshaTe;

  final int varaNumber;
  final String varaNameTe;
  final String varaNameEn;

  final int nakshatraNumber;
  final String nakshatraNameTe;
  final String nakshatraNameEn;
  final DateTime nakshatraEndTime;

  final int yogaNumber;
  final String yogaNameTe;
  final String yogaNameEn;
  final DateTime yogaEndTime;

  final int karanaNumber;
  final String karanaNameTe;
  final String karanaNameEn;
  final DateTime karanaEndTime;

  // ── Daily Timings ─────────────────────────────────────────────────────────
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime? moonrise;
  final DateTime? moonset;

  // ── Inauspicious Periods ──────────────────────────────────────────────────
  final DateTime rahuKalamStart;
  final DateTime rahuKalamEnd;
  final DateTime gulikaKalamStart;
  final DateTime gulikaKalamEnd;
  final DateTime yamagandaStart;
  final DateTime yamagandaEnd;

  // ── Muhurthas ─────────────────────────────────────────────────────────────
  final DateTime? abhijitStart;
  final DateTime? abhijitEnd;
  final bool abhijitValid;
  final DateTime durMuhurtaStart;
  final DateTime durMuhurtaEnd;
  final DateTime amritKalamStart;
  final DateTime amritKalamEnd;

  // ── Calendar Context ──────────────────────────────────────────────────────
  final String teluguMonthTe;
  final String teluguMonthEn;
  final int teluguMonthNumber;
  final String samvatsaraTe;
  final String samvatsaraEn;
  final String ayanamTe;
  final String ayanamEn;
  final String rituTe;
  final String rituEn;
  final int rashiNumber;
  final String rashiNameTe;
  final String rashiNameEn;
  final int shakaYear;

  const PanchangamData({
    required this.date,
    required this.lat,
    required this.lng,
    required this.tithiNumber,
    required this.tithiNameTe,
    required this.tithiNameEn,
    required this.tithiEndTime,
    required this.paksha,
    required this.pakshaTe,
    required this.varaNumber,
    required this.varaNameTe,
    required this.varaNameEn,
    required this.nakshatraNumber,
    required this.nakshatraNameTe,
    required this.nakshatraNameEn,
    required this.nakshatraEndTime,
    required this.yogaNumber,
    required this.yogaNameTe,
    required this.yogaNameEn,
    required this.yogaEndTime,
    required this.karanaNumber,
    required this.karanaNameTe,
    required this.karanaNameEn,
    required this.karanaEndTime,
    required this.sunrise,
    required this.sunset,
    this.moonrise,
    this.moonset,
    required this.rahuKalamStart,
    required this.rahuKalamEnd,
    required this.gulikaKalamStart,
    required this.gulikaKalamEnd,
    required this.yamagandaStart,
    required this.yamagandaEnd,
    this.abhijitStart,
    this.abhijitEnd,
    required this.abhijitValid,
    required this.durMuhurtaStart,
    required this.durMuhurtaEnd,
    required this.amritKalamStart,
    required this.amritKalamEnd,
    required this.teluguMonthTe,
    required this.teluguMonthEn,
    required this.teluguMonthNumber,
    required this.samvatsaraTe,
    required this.samvatsaraEn,
    required this.ayanamTe,
    required this.ayanamEn,
    required this.rituTe,
    required this.rituEn,
    required this.rashiNumber,
    required this.rashiNameTe,
    required this.rashiNameEn,
    required this.shakaYear,
  });
}

/// Lighter data class for calendar grid cells (avoids full engine computation).
class DayData {
  final DateTime date;
  final int tithiNumber;
  final String tithiNameTe;
  final String tithiNameEn;
  final int nakshatraNumber;
  final String nakshatraNameTe;
  final String nakshatraNameEn;
  final bool isFestival;
  final List<String> festivalNamesTe;
  final List<String> festivalNamesEn;

  const DayData({
    required this.date,
    required this.tithiNumber,
    required this.tithiNameTe,
    required this.tithiNameEn,
    required this.nakshatraNumber,
    required this.nakshatraNameTe,
    required this.nakshatraNameEn,
    this.isFestival = false,
    this.festivalNamesTe = const [],
    this.festivalNamesEn = const [],
  });

  /// Compute a DayData (lighter than full PanchangamData) for the calendar grid.
  static DayData compute(DateTime date, double lat, double lng) {
    // Use sunrise JD as reference (Panchangam convention)
    final List<DateTime> sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
    final double jdSunrise = JulianDay.fromIST(sunTimes[0]);

    final int tNum = Tithi.number(jdSunrise);
    final int nNum = Nakshatra.number(jdSunrise);

    return DayData(
      date: DateTime(date.year, date.month, date.day),
      tithiNumber: tNum,
      tithiNameTe: Tithi.namesTe[tNum - 1],
      tithiNameEn: Tithi.namesEn[tNum - 1],
      nakshatraNumber: nNum,
      nakshatraNameTe: Nakshatra.namesTe[nNum - 1],
      nakshatraNameEn: Nakshatra.namesEn[nNum - 1],
    );
  }
}

/// Parameters for isolate-based month computation.
class MonthComputeParams {
  final int year;
  final int month;
  final double lat;
  final double lng;

  const MonthComputeParams({
    required this.year,
    required this.month,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() => {
        'year': year,
        'month': month,
        'lat': lat,
        'lng': lng,
      };

  factory MonthComputeParams.fromMap(Map<String, dynamic> m) =>
      MonthComputeParams(
        year: m['year'] as int,
        month: m['month'] as int,
        lat: m['lat'] as double,
        lng: m['lng'] as double,
      );
}

/// Top-level function for use with Flutter's [compute()] isolate helper.
List<DayData> computeMonthData(MonthComputeParams params) {
  final int daysInMonth =
      DateTime(params.year, params.month + 1, 0).day;
  final List<DayData> result = [];

  for (int day = 1; day <= daysInMonth; day++) {
    final DateTime date = DateTime(params.year, params.month, day);
    result.add(DayData.compute(date, params.lat, params.lng));
  }
  return result;
}
