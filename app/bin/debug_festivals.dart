import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/tithi.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/telugu_calendar.dart';
import 'package:panchangam/core/calculations/ayanamsa.dart';
import 'package:panchangam/core/calculations/solar_position.dart';

const double lat = 17.385, lng = 78.4867;

void check(DateTime date) {
  final sr = SunriseSunset.computeNOAA(date, lat, lng)[0];
  final jd = JulianDay.fromIST(sr);
  final tNum = Tithi.number(jd);
  final mNum = TeluguCalendar.monthNumber(jd);
  final tropLon = SolarPosition.tropicalLongitude(jd);
  final sidLon = SolarPosition.siderealLongitude(jd);
  final ayan = Ayanamsa.lahiri(jd);
  final rashi = (sidLon / 30).floor();
  print(
    '${date.toString().substring(0, 10)}: '
    'tithi=$tNum month=$mNum '
    'trop=${tropLon.toStringAsFixed(1)}° '
    'sid=${sidLon.toStringAsFixed(1)}° (rashi=$rashi) '
    'ayanamsa=${ayan.toStringAsFixed(2)}°',
  );
}

void main() {
  print('--- Diwali candidates ---');
  check(DateTime(2024, 11, 1)); // Commonly cited as Diwali 2024
  check(DateTime(2024, 12, 1)); // What our code shows as Deepavali
  print('');
  print('--- Vaikunta Ekadashi candidates ---');
  check(DateTime(2025, 12, 1));  // Old code fired here (month 9)
  check(DateTime(2025, 12, 29));
  check(DateTime(2025, 12, 30)); // Sringeri says correct
  check(DateTime(2025, 12, 31));
  check(DateTime(2026, 1, 1));
  print('');
  print('--- Dhanteras duplicate check ---');
  check(DateTime(2025, 11, 17));
  check(DateTime(2025, 11, 18));
}
