/// Amrit Kalam verification script.
/// Scans upcoming dates to find one occurrence of each of the 27 nakshatras,
/// then prints the computed Amrit Kalam time for each.
///
/// Run with: dart run bin/validate_amrit.dart
///
/// Output: one row per nakshatra — date, nakshatra, computed time.
/// Compare against DrikPanchang (Hyderabad) to verify the ghati table.

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/calculations/muhurtha.dart';

// Hyderabad
const double lat = 17.3850;
const double lng = 78.4867;

void main() {
  // Scan from today for up to 60 days — enough to cover all 27 nakshatras.
  final start = DateTime(2026, 2, 27);
  final Map<int, _Row> found = {};

  for (int i = 0; i < 60; i++) {
    final date = start.add(Duration(days: i));
    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sunrise = times[0];
    final jd = JulianDay.fromIST(sunrise);
    final nNum = Nakshatra.number(jd);

    if (!found.containsKey(nNum)) {
      final sunset = times[1];
      final amrit = Muhurtha.amritKalam(nNum, sunrise, sunset);
      found[nNum] = _Row(date, nNum, Nakshatra.namesTe[nNum - 1], sunrise, amrit);
    }

    if (found.length == 27) break;
  }

  print('Amrit Kalam Verification Table — Hyderabad');
  print('Compare against DrikPanchang for each date/nakshatra');
  print('');
  print('${'#'.padLeft(2)}  ${'Nakshatra'.padRight(22)}  ${'Date'.padRight(12)}  ${'Sunrise'.padRight(8)}  Amrit Kalam (our app)');
  print('─' * 80);

  for (int n = 1; n <= 27; n++) {
    final row = found[n];
    if (row == null) {
      print('${n.toString().padLeft(2)}  ${'(not found in scan)'.padRight(22)}');
      continue;
    }
    final dateStr =
        '${row.date.year}-${row.date.month.toString().padLeft(2, '0')}-${row.date.day.toString().padLeft(2, '0')}';
    final sunriseStr = _fmt(row.sunrise);
    final amritStr = row.amrit == null
        ? 'Not applicable'
        : '${_fmt(row.amrit![0])} – ${_fmt(row.amrit![1])}';

    print('${n.toString().padLeft(2)}  ${row.nakshatraName.padRight(22)}  ${dateStr.padRight(12)}  ${sunriseStr.padRight(8)}  $amritStr');
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
  final DateTime sunrise;
  final List<DateTime>? amrit;

  _Row(this.date, this.nakshatraNum, this.nakshatraName, this.sunrise, this.amrit);
}
