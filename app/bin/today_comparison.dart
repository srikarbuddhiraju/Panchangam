/// Compute today's Panchangam for Kondavidu and show all elements.
/// Run: dart run bin/today_comparison.dart
library;

import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/solar_position.dart';
import 'package:panchangam/core/calculations/tithi.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/yoga.dart';
import 'package:panchangam/core/calculations/karana.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/ayanamsa.dart';
import 'package:panchangam/core/calculations/muhurtha.dart';

const double lat = 16.5167;
const double lng = 80.5000; // Kondavidu (Sringeri reference meridian)

void main() {
  final today = DateTime(2026, 3, 13);
  final ss = SunriseSunset.computeNOAA(today, lat, lng);
  final sunrise = ss[0];
  final sunset  = ss[1];

  final jdSunrise = JulianDay.fromIST(sunrise);

  // Moon & Sun longitudes at sunrise
  final moonLon = LunarPosition.siderealLongitude(jdSunrise);
  final sunLon  = SolarPosition.siderealLongitude(jdSunrise);

  // Five elements at sunrise
  final tithiNum    = Tithi.number(jdSunrise);
  final tithiName   = Tithi.namesEn[tithiNum - 1];
  final nkNum       = Nakshatra.number(jdSunrise);
  final nkName      = Nakshatra.namesEn[nkNum - 1];
  final yogaNum     = Yoga.number(jdSunrise);
  final yogaName    = Yoga.namesEn[yogaNum - 1];
  final karanaNum   = Karana.number(jdSunrise);
  final karanaName  = Karana.nameEn(karanaNum);

  // Ending times
  final tithiEnd = Tithi.endTime(jdSunrise);
  final nkEnd    = Nakshatra.endTime(jdSunrise);
  final yogaEnd  = Yoga.endTime(jdSunrise);

  // Amrit kalam (lookup table)
  final amritLookup = Muhurtha.amritKalam(
    nkNum, 5, sunrise, sunset, sunrise.subtract(const Duration(days: 1)), lng: lng);
  final amritFormula = Muhurtha.amritKalamFormulaOnly(sunrise, lng: lng);

  // Ayanamsha
  final ayanamsha = Ayanamsa.trueChhitraPaksha(jdSunrise);

  print('=== Panchangam for Mar 13, 2026 — Kondavidu (${lat}N, ${lng}E) ===');
  print('');
  print('Sunrise : ${_fmt(sunrise)}');
  print('Sunset  : ${_fmt(sunset)}');
  print('Ayanamsha (TCP): ${ayanamsha.toStringAsFixed(4)}°');
  print('Moon lon (sidereal): ${moonLon.toStringAsFixed(3)}°');
  print('Sun  lon (sidereal): ${sunLon.toStringAsFixed(3)}°');
  print('');
  print('─── Five Elements at Sunrise ───────────────────────────────');
  print('Vara      : Shukravara (Friday = 5)');
  print('Tithi     : $tithiName (#$tithiNum)  ends: ${_fmt(tithiEnd)}');
  print('Nakshatra : $nkName (#$nkNum)  ends: ${_fmt(nkEnd)}');
  print('Yoga      : $yogaName (#$yogaNum)  ends: ${_fmt(yogaEnd)}');
  print('Karana    : $karanaName (#$karanaNum)');
  print('');
  print('─── Amrit Kalam ────────────────────────────────────────────');
  print('Lookup table (Sringeri exact): ${amritLookup != null ? "${_fmt(amritLookup[0])} – ${_fmt(amritLookup[1])}" : "none"}');
  print('Formula fallback (Ramakumar) : ${amritFormula != null ? "${_fmt(amritFormula[0])} – ${_fmt(amritFormula[1])}" : "none"}');
  if (amritLookup != null && amritFormula != null) {
    final diff = amritLookup[0].difference(amritFormula[0]).inMinutes.abs();
    print('Formula error vs lookup      : $diff min');
  }
}

String _fmt(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m IST';
}
