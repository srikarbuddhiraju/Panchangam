/// Calibrate Ramakumar X values empirically from Sringeri 464-entry dataset.
///
/// For each data point:
///   empiricalX = (amritaStart − nkEntry) / nkDuration × 24
///
/// Group by nakshatra → compute mean X per nakshatra.
/// Then re-run accuracy with calibrated X values vs Ramakumar X values.
///
/// Run: dart run bin/calibrate_x_values.dart
library;

import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';
import 'package:panchangam/core/data/amrita_lookup.dart';

const double _lat = 16.5167;
const double _lng = 80.5000;
const double _nkSpan = 360.0 / 27;

const List<String> _nkNames = [
  'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha',
  'Ardra', 'Punarvasu', 'Pushyami', 'Ashlesha', 'Makha',
  'Pubba', 'Uttara', 'Hasta', 'Chitra', 'Swati',
  'Vishakha', 'Anuradha', 'Jyeshtha', 'Moola', 'Purvashadha',
  'Uttarashadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
  'Purvabhadra', 'Uttarabhadra', 'Revati',
];

// Ramakumar X values for comparison
const List<double> _ramakumarX = [
  16.8, 19.2, 21.6, 20.8, 15.2, 14.0, 21.6, 17.6, 22.4, 21.6,
  17.6, 16.8, 18.0, 17.6, 15.2, 15.2, 13.6, 15.2, 17.6, 19.2,
  17.6, 13.6, 13.6, 16.8, 16.0, 19.2, 21.6,
];

DateTime _bisectLon({
  required DateTime from,
  required DateTime to,
  required double targetLon,
}) {
  double lo = JulianDay.fromIST(from);
  double hi = JulianDay.fromIST(to);
  for (int i = 0; i < 50; i++) {
    final double mid = (lo + hi) / 2;
    final double lon = LunarPosition.siderealLongitude(mid);
    final double dist = (targetLon - lon + 360.0) % 360.0;
    if (dist > 0.0 && dist < 180.0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return JulianDay.toIST((lo + hi) / 2);
}

void main() {
  final all = AmritaLookup.allEntries;

  // Per-nakshatra buckets of empirical X values
  final List<List<double>> xBuckets = List.generate(27, (_) => []);
  int skipped = 0;

  for (final entry in all.entries) {
    final parts = entry.key.split('-');
    final int y = int.parse(parts[0]);
    final int mo = int.parse(parts[1]);
    final int d = int.parse(parts[2]);
    final (int eh, int em) = entry.value;
    final DateTime expected = DateTime.utc(y, mo, d, eh, em);

    // Try ±1 day sunrise to handle pre-dawn Ra.Amrita
    double? bestX;
    int? bestNk;

    for (int delta = -1; delta <= 1; delta++) {
      final DateTime date = DateTime(y, mo, d).add(Duration(days: delta));
      final List<DateTime> ss = SunriseSunset.computeNOAA(date, _lat, _lng);
      final DateTime sunrise = ss[0];

      final double jdSunrise = JulianDay.fromIST(sunrise);
      final double moonLon = LunarPosition.siderealLongitude(jdSunrise);
      int nkIdx = (moonLon / _nkSpan).floor() % 27;

      double nkEndLon = ((nkIdx + 1) % 27) * _nkSpan;
      DateTime nkExit = _bisectLon(
        from: sunrise,
        to: sunrise.add(const Duration(hours: 48)),
        targetLon: nkEndLon,
      );

      // Apply 1h rule
      if (nkExit.difference(sunrise).inMinutes < 60) {
        nkIdx = (nkIdx + 1) % 27;
        final double nextNkEndLon = ((nkIdx + 1) % 27) * _nkSpan;
        final DateTime prevExit = nkExit;
        nkExit = _bisectLon(
          from: prevExit,
          to: prevExit.add(const Duration(hours: 48)),
          targetLon: nextNkEndLon,
        );
        nkEndLon = nextNkEndLon;
      }

      final double nkStartLon = nkIdx * _nkSpan;
      final DateTime nkEntry = _bisectLon(
        from: sunrise.subtract(const Duration(hours: 48)),
        to: sunrise,
        targetLon: nkStartLon,
      );

      final double nkDurationHrs = nkExit.difference(nkEntry).inMinutes / 60.0;
      if (nkDurationHrs < 15.0 || nkDurationHrs > 30.0) continue;

      final double offsetHrs = expected.difference(nkEntry).inMinutes / 60.0;
      final double xVal = offsetHrs / nkDurationHrs * 24.0;

      // Only accept plausible X values (0–24 range, amrita must be within NK)
      if (xVal < 0.0 || xVal > 24.0) continue;

      // Take the delta that gives X closest to the midpoint (most plausible)
      if (bestX == null || (xVal - 12.0).abs() < (bestX - 12.0).abs()) {
        bestX = xVal;
        bestNk = nkIdx;
      }
    }

    if (bestX == null || bestNk == null) {
      skipped++;
    } else {
      xBuckets[bestNk!].add(bestX!);
    }
  }

  // Compute calibrated X (mean per nakshatra)
  final List<double> calibX = List.filled(27, 0.0);
  print('── Empirical X per Nakshatra ─────────────────────────────────────────');
  print('${'NK'.padRight(16)} ${'n'.padLeft(3)} ${'Ramakumar'.padLeft(10)} ${'Empirical'.padLeft(10)} ${'StdDev'.padLeft(8)}');
  for (int i = 0; i < 27; i++) {
    final bucket = xBuckets[i];
    if (bucket.isEmpty) {
      calibX[i] = _ramakumarX[i]; // fall back to Ramakumar if no data
      print('${_nkNames[i].padRight(16)} ${'0'.padLeft(3)} ${_ramakumarX[i].toStringAsFixed(1).padLeft(10)} ${'(no data)'.padLeft(10)}');
    } else {
      final mean = bucket.fold(0.0, (a, b) => a + b) / bucket.length;
      final variance = bucket.fold(0.0, (a, b) => a + (b - mean) * (b - mean)) / bucket.length;
      final stddev = variance < 0 ? 0.0 : variance > 0 ? variance : 0.0;
      calibX[i] = mean;
      print('${_nkNames[i].padRight(16)} ${bucket.length.toString().padLeft(3)} ${_ramakumarX[i].toStringAsFixed(1).padLeft(10)} ${mean.toStringAsFixed(2).padLeft(10)} ${stddev.toStringAsFixed(2).padLeft(8)}');
    }
  }
  print('Skipped: $skipped');
  print('');

  // Now compare accuracy: Ramakumar X vs Calibrated X
  print('── Accuracy comparison ───────────────────────────────────────────────');
  final List<int> errRamakumar = [];
  final List<int> errCalib = [];

  for (final entry in all.entries) {
    final parts = entry.key.split('-');
    final int y = int.parse(parts[0]);
    final int mo = int.parse(parts[1]);
    final int d = int.parse(parts[2]);
    final (int eh, int em) = entry.value;
    final DateTime expected = DateTime.utc(y, mo, d, eh, em);

    int? bestR, bestC;

    for (int delta = -1; delta <= 1; delta++) {
      final DateTime date = DateTime(y, mo, d).add(Duration(days: delta));
      final List<DateTime> ss = SunriseSunset.computeNOAA(date, _lat, _lng);
      final DateTime sunrise = ss[0];

      final double jdSunrise = JulianDay.fromIST(sunrise);
      final double moonLon = LunarPosition.siderealLongitude(jdSunrise);
      int nkIdx = (moonLon / _nkSpan).floor() % 27;

      double nkEndLon = ((nkIdx + 1) % 27) * _nkSpan;
      DateTime nkExit = _bisectLon(
        from: sunrise,
        to: sunrise.add(const Duration(hours: 48)),
        targetLon: nkEndLon,
      );

      if (nkExit.difference(sunrise).inMinutes < 60) {
        nkIdx = (nkIdx + 1) % 27;
        final double nextNkEndLon = ((nkIdx + 1) % 27) * _nkSpan;
        final DateTime prevExit = nkExit;
        nkExit = _bisectLon(
          from: prevExit,
          to: prevExit.add(const Duration(hours: 48)),
          targetLon: nextNkEndLon,
        );
      }

      final double nkStartLon = nkIdx * _nkSpan;
      final DateTime nkEntry = _bisectLon(
        from: sunrise.subtract(const Duration(hours: 48)),
        to: sunrise,
        targetLon: nkStartLon,
      );

      final double nkDurationHrs = nkExit.difference(nkEntry).inMinutes / 60.0;
      if (nkDurationHrs < 15.0 || nkDurationHrs > 30.0) continue;

      int _err(double x) {
        final int offsetMin = ((x / 24.0) * nkDurationHrs * 60.0).round();
        final DateTime start = nkEntry.add(Duration(minutes: offsetMin));
        int e = start.difference(expected).inMinutes.abs();
        final int wrapped = (24 * 60 - e).abs();
        if (wrapped < e) e = wrapped;
        return e;
      }

      final int eR = _err(_ramakumarX[nkIdx]);
      final int eC = _err(calibX[nkIdx]);

      if (bestR == null || eR < bestR) bestR = eR;
      if (bestC == null || eC < bestC) bestC = eC;
    }

    if (bestR != null) errRamakumar.add(bestR!);
    if (bestC != null) errCalib.add(bestC!);
  }

  void printStats(String label, List<int> errs) {
    final sorted = List.of(errs)..sort();
    final n = sorted.length;
    if (n == 0) { print('$label: no data'); return; }
    final w15 = sorted.where((e) => e <= 15).length;
    final w30 = sorted.where((e) => e <= 30).length;
    final w60 = sorted.where((e) => e <= 60).length;
    final mean = sorted.fold(0, (a, b) => a + b) / n;
    print('$label (n=$n): ≤15=${(w15/n*100).toStringAsFixed(1)}%  ≤30=${(w30/n*100).toStringAsFixed(1)}%  ≤60=${(w60/n*100).toStringAsFixed(1)}%  mean=${mean.toStringAsFixed(0)}m  median=${sorted[n~/2]}m');
  }

  printStats('Ramakumar X', errRamakumar);
  printStats('Calibrated X', errCalib);

  // Print calibrated X array for copy-paste into muhurtha.dart
  print('');
  print('── Calibrated _amritX array (paste into muhurtha.dart) ───────────────');
  for (int i = 0; i < 27; i++) {
    print('    ${calibX[i].toStringAsFixed(2)}, // ${i+1} ${_nkNames[i]}');
  }
}
