/// Computes nakshatra at sunrise + sunrise/sunset for April and August 2025
/// Used to cross-reference with Sringeri OCR amrita times.
/// Run: dart run bin/compute_feb_offsets.dart
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 12.9716;
const double lng = 77.5946;
const double nkSpan = 360.0 / 27;

const List<String> nkNames = [
  '', 'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
  'PurvaPhalguni', 'UttaraPhalguni', 'Hasta', 'Chitra', 'Swati',
  'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'PurvaAshadha',
  'UttaraAshadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
  'PurvaBhadrapada', 'UttaraBhadrapada', 'Revati',
];

const List<String> varaNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

void printMonth(int year, int month, String label) {
  print('\n─── $label ───────────────────────────────────────────');
  print('Day  Vara  NK# Nakshatra         Sunrise  Sunset   DayLen');
  print('─' * 65);
  final days = DateTime(year, month + 1, 0).day;
  for (int d = 1; d <= days; d++) {
    final date = DateTime(year, month, d);
    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sunrise = times[0];
    final sunset  = times[1];
    final jdSR = JulianDay.fromIST(sunrise);
    final lon = LunarPosition.siderealLongitude(jdSR);
    final nk = ((lon / nkSpan).floor() % 27) + 1;
    final vara = date.weekday % 7;
    final dayLen = sunset.difference(sunrise).inMinutes;
    print('${d.toString().padLeft(3)}  ${varaNames[vara]}  '
        '${nk.toString().padLeft(2)} ${nkNames[nk].padRight(16)}  '
        '${_t(sunrise)}   ${_t(sunset)}  ${dayLen}min');
  }
}

void main() {
  printMonth(2025, 4, 'April 2025 — Bengaluru');
  printMonth(2025, 8, 'August 2025 — Bengaluru');
}

String _t(DateTime dt) =>
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
