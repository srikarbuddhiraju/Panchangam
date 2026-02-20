/// Standalone validation script — run with: dart run bin/validate.dart
/// Prints Panchangam values for Hyderabad for several reference dates.
/// Compare output against drikpanchang.com to check accuracy.

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/solar_position.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/tithi.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/yoga.dart';
import 'package:panchangam/core/calculations/karana.dart';
import 'package:panchangam/core/calculations/vara.dart';
import 'package:panchangam/core/calculations/kalam_timings.dart';
import 'package:panchangam/core/calculations/telugu_calendar.dart';

// Hyderabad
const double lat = 17.3850;
const double lng = 78.4867;

void main() {
  final dates = [
    DateTime(2026, 2, 20),  // Today
    DateTime(2025, 4, 14),  // Ugadi 2025 (Telugu New Year)
    DateTime(2025, 1, 14),  // Makar Sankranti 2025
    DateTime(2025, 10, 2),  // Navami (Dasara period)
    DateTime(2024, 11, 1),  // Diwali 2024 (Amavasya)
  ];

  for (final date in dates) {
    _printDay(date);
    print('');
  }
}

String _fmtTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m IST';
}

void _printDay(DateTime date) {
  final times = SunriseSunset.computeNOAA(date, lat, lng);
  final sunrise = times[0];
  final sunset = times[1];
  final jd = JulianDay.fromIST(sunrise);

  // Five limbs
  final tNum = Tithi.number(jd);
  final tEnd = Tithi.endTime(jd);
  final tName = Tithi.namesTe[tNum - 1];
  final tPaksha = Tithi.pakshaTe(tNum);

  final nNum = Nakshatra.number(jd);
  final nEnd = Nakshatra.endTime(jd);
  final nName = Nakshatra.namesTe[nNum - 1];

  final yNum = Yoga.number(jd);
  final yEnd = Yoga.endTime(jd);
  final yName = Yoga.namesTe[yNum - 1];

  final kNum = Karana.number(jd);
  final kName = Karana.nameTe(kNum);

  final vNum = Vara.number(jd);
  final vName = Vara.namesTe[vNum];

  // Telugu calendar context
  final jdMid = JulianDay.fromDateTime(date.year, date.month, 15, 6, 0, 0);
  final monthNum = TeluguCalendar.monthNumber(jdMid);
  final monthName = TeluguCalendar.monthNamesTe[monthNum - 1];
  final shakaYr = TeluguCalendar.shakaYear(date);
  final samvatsara = TeluguCalendar.samvatsaraTe(shakaYr);

  // Sun/Moon longitudes (for debugging accuracy)
  final sunLon = SolarPosition.siderealLongitude(jd);
  final moonLon = LunarPosition.siderealLongitude(jd);
  final moonSunDiff = (moonLon - sunLon + 360) % 360;

  // Kalam
  final rahuTimes = KalamTimings.rahuKalam(vNum, sunrise, sunset);
  final gulikaTimes = KalamTimings.gulikaKalam(vNum, sunrise, sunset);
  final yamaTimes = KalamTimings.yamaganda(vNum, sunrise, sunset);

  print('═══════════════════════════════════════════════════════');
  print('DATE: ${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} | Hyderabad');
  print('═══════════════════════════════════════════════════════');
  print('Vara (వారం)      : $vName (#$vNum)');
  print('Sunrise          : ${_fmtTime(sunrise)}');
  print('Sunset           : ${_fmtTime(sunset)}');
  print('');
  print('── Five Limbs (పంచాంగం) ──────────────────────────────');
  print('Tithi (తిథి)     : $tName ($tPaksha) #$tNum  → ends ${_fmtTime(tEnd)}');
  print('Nakshatra (నక్ష) : $nName #$nNum  → ends ${_fmtTime(nEnd)}');
  print('Yoga (యోగం)      : $yName #$yNum  → ends ${_fmtTime(yEnd)}');
  print('Karana (కరణం)    : $kName #$kNum');
  print('');
  print('── Telugu Calendar ───────────────────────────────────');
  print('Month            : $monthName  (#$monthNum)');
  print('Samvatsara       : $samvatsara  (Shaka $shakaYr)');
  print('');
  print('── Debug Longitudes ──────────────────────────────────');
  print('Sun sidereal     : ${sunLon.toStringAsFixed(3)}°');
  print('Moon sidereal    : ${moonLon.toStringAsFixed(3)}°');
  print('Moon-Sun diff    : ${moonSunDiff.toStringAsFixed(3)}°  (tithi = ${(moonSunDiff/12).toStringAsFixed(2)} × 12°)');
  print('');
  print('── Kalam ─────────────────────────────────────────────');
  print('Rahu Kalam       : ${_fmtTime(rahuTimes[0])} – ${_fmtTime(rahuTimes[1])}');
  print('Gulika Kalam     : ${_fmtTime(gulikaTimes[0])} – ${_fmtTime(gulikaTimes[1])}');
  print('Yamaganda        : ${_fmtTime(yamaTimes[0])} – ${_fmtTime(yamaTimes[1])}');
}
