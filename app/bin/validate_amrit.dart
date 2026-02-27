/// Amrit Kalam verification script.
/// Scans upcoming dates to find one occurrence of each nakshatra×weekday combo
/// that has a verified entry, then prints the computed time.
///
/// Run with: dart run bin/validate_amrit.dart

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/muhurtha.dart';
import 'package:panchangam/core/calculations/vara.dart';

// Hyderabad
const double lat = 17.3850;
const double lng = 78.4867;

const List<String> _varaNamesEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

void main() {
  // Scan 60 days — enough to cover all 27 nakshatras across all weekdays.
  final start = DateTime(2026, 2, 27);
  // Key: nakshatra*10 + vara (to find one date per nakshatra+vara combo)
  final Map<int, _Row> found = {};

  for (int i = 0; i < 60; i++) {
    final date = start.add(Duration(days: i));
    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sunrise = times[0];
    final sunset = times[1];
    final jd = JulianDay.fromIST(sunrise);
    final nNum = Nakshatra.number(jd);
    final vara = Vara.fromDateTime(date);
    final key = nNum * 10 + vara;

    if (!found.containsKey(key)) {
      final amrit = Muhurtha.amritKalam(nNum, vara, sunrise, sunset);
      found[key] = _Row(date, nNum, Nakshatra.namesTe[nNum - 1], vara, sunrise, sunset, amrit);
    }
  }

  print('Amrit Kalam Verification Table — Hyderabad (nakshatra × weekday)');
  print('Only rows with a verified entry are shown. Compare clock times against Sringeri PDF.');
  print('');
  print('${'#'.padLeft(2)}  ${'Nakshatra'.padRight(22)}  Day  ${'Date'.padRight(12)}  ${'Sunrise'.padRight(8)}  ${'Sunset'.padRight(8)}  Amrit Kalam');
  print('─' * 90);

  // Print only rows where amrit is not null (verified entries)
  final rows = found.values.toList()
    ..sort((a, b) => a.nakshatraNum != b.nakshatraNum
        ? a.nakshatraNum.compareTo(b.nakshatraNum)
        : a.vara.compareTo(b.vara));

  for (final row in rows) {
    if (row.amrit == null) continue;
    final dateStr =
        '${row.date.year}-${row.date.month.toString().padLeft(2, '0')}-${row.date.day.toString().padLeft(2, '0')}';
    final amritStr = '${_fmt(row.amrit![0])} – ${_fmt(row.amrit![1])}';
    print('${row.nakshatraNum.toString().padLeft(2)}  ${row.nakshatraName.padRight(22)}  ${_varaNamesEn[row.vara]}  ${dateStr.padRight(12)}  ${_fmt(row.sunrise).padRight(8)}  ${_fmt(row.sunset).padRight(8)}  $amritStr');
  }
}

String _fmt(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _Row {
  final DateTime date;
  final int nakshatraNum;
  final String nakshatraName;
  final int vara;
  final DateTime sunrise;
  final DateTime sunset;
  final List<DateTime>? amrit;

  _Row(this.date, this.nakshatraNum, this.nakshatraName, this.vara,
      this.sunrise, this.sunset, this.amrit);
}
