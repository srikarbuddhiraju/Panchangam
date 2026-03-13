/// NK-label-filtered X calibration.
/// Fixes: CSV uses 0-based nk_idx (Ashwini=0, Revati=26).
///        Only Di.Amrita used — Ra times have date ambiguity.
/// Run: dart run bin/calibrate_nk_filtered.dart
library;

import 'dart:io';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 16.5167;
const double lng = 80.5000; // Kondavidu

const double nkSpan = 360.0 / 27;

const List<double> ramakumarX = [
  16.8, 19.2, 21.6, 20.8, 15.2, 14.0, 21.6, 17.6, 22.4, 21.6,
  17.6, 16.8, 18.0, 17.6, 15.2, 15.2, 13.6, 15.2, 17.6, 19.2,
  17.6, 13.6, 13.6, 16.8, 16.0, 19.2, 21.6,
];

const nkNames = [
  'Ashwini','Bharani','Krttika','Rohini','Mrigashirsha',
  'Ardra','Punarvasu','Pushya','Ashlesha','Magha','PvPhg',
  'UtPhg','Hasta','Chitra','Swati','Vishakha','Anuradha',
  'Jyeshtha','Moola','PvAshadha','UtAshadha','Shravana',
  'Dhanishtha','Shatabhisha','PvBhadra','UtBhadra','Revati',
];

DateTime bisectLon({required DateTime from, required DateTime to, required double targetLon}) {
  double lo = JulianDay.fromIST(from);
  double hi = JulianDay.fromIST(to);
  for (int i = 0; i < 50; i++) {
    final mid = (lo + hi) / 2;
    final lon = LunarPosition.siderealLongitude(mid);
    final dist = (targetLon - lon + 360.0) % 360.0;
    if (dist > 0.0 && dist < 180.0) lo = mid; else hi = mid;
  }
  return JulianDay.toIST((lo + hi) / 2);
}

class Entry {
  final DateTime date;
  final int nkIdx0; // 0-based from CSV
  final DateTime amritaTime; // absolute IST
  Entry(this.date, this.nkIdx0, this.amritaTime);
}

List<Entry> loadCsv(String path) {
  final entries = <Entry>[];
  for (final line in File(path).readAsLinesSync().skip(1)) {
    final cols = line.split(',');
    if (cols.length < 5) continue;
    final parts = cols[0].split('-');
    if (parts.length != 3) continue;
    final y = int.tryParse(parts[0]);
    final mo = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || mo == null || d == null) continue;
    final nkIdx0 = int.tryParse(cols[2]);
    if (nkIdx0 == null || nkIdx0 < 0 || nkIdx0 > 26) continue;
    final type = cols[3].trim();
    if (type != 'Di') continue; // Di only — Ra times have date ambiguity
    final timeParts = cols[4].trim().split(':');
    if (timeParts.length != 2) continue;
    final h = int.tryParse(timeParts[0]);
    final m = int.tryParse(timeParts[1]);
    if (h == null || m == null) continue;
    final amritaTime = h >= 24
        ? DateTime(y, mo, d + 1, h - 24, m)
        : DateTime(y, mo, d, h, m);
    entries.add(Entry(DateTime(y, mo, d), nkIdx0, amritaTime));
  }
  return entries;
}

int computeOurNkIdx0(DateTime date) {
  final ss = SunriseSunset.computeNOAA(date, lat, lng);
  final sunrise = ss[0];
  final jdSunrise = JulianDay.fromIST(sunrise);
  final moonLon = LunarPosition.siderealLongitude(jdSunrise);
  int nkIdx0 = (moonLon / nkSpan).floor() % 27; // 0-based

  // 1h rule: if current NK exits within 60 min of sunrise, use next
  final nkEndLon = ((nkIdx0 + 1) % 27) * nkSpan;
  final nkExit = bisectLon(
    from: sunrise, to: sunrise.add(const Duration(hours: 48)), targetLon: nkEndLon,
  );
  if (nkExit.difference(sunrise).inMinutes < 60) {
    nkIdx0 = (nkIdx0 + 1) % 27;
  }
  return nkIdx0;
}

void main() {
  final entries = [
    ...loadCsv('/var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/docs/data/amrita_2526.csv'),
    ...loadCsv('/var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/docs/data/amrita_2627.csv'),
  ];

  print('Di.Amrita entries loaded: ${entries.length}');

  // Per-NK empirical X values (NK-match only)
  final xValues = List<List<double>>.generate(27, (_) => []);
  int matched = 0, unmatched = 0;

  for (final e in entries) {
    final ourNkIdx0 = computeOurNkIdx0(e.date);
    if (ourNkIdx0 != e.nkIdx0) { unmatched++; continue; }
    matched++;

    final ss = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sunrise = ss[0];
    final nkStartLon = e.nkIdx0 * nkSpan;
    final nkEndLon   = ((e.nkIdx0 + 1) % 27) * nkSpan;

    final nkEntry = bisectLon(
      from: sunrise.subtract(const Duration(hours: 48)), to: sunrise, targetLon: nkStartLon,
    );
    final nkExit = bisectLon(
      from: sunrise, to: sunrise.add(const Duration(hours: 48)), targetLon: nkEndLon,
    );
    final nkDurHrs = nkExit.difference(nkEntry).inMinutes / 60.0;
    if (nkDurHrs < 15 || nkDurHrs > 30) continue;

    final durMin = e.amritaTime.difference(nkEntry).inMinutes.toDouble();
    if (durMin < 0 || durMin > nkDurHrs * 60 + 60) continue;

    final empiricalX = durMin / (nkDurHrs * 60.0) * 24.0;
    if (empiricalX < 0 || empiricalX >= 24) continue;

    xValues[e.nkIdx0].add(empiricalX);
  }

  print('NK-match: $matched  Mismatch: $unmatched  '
        'Match rate: ${(matched/(matched+unmatched)*100).toStringAsFixed(1)}%\n');

  print('NK               N   Ramakumar  Sringeri-X  StdDev  Δ vs Ramakumar');
  print('─' * 72);

  final calibratedX = List<double>.from(ramakumarX);

  for (int i = 0; i < 27; i++) {
    final vals = xValues[i];
    final rX = ramakumarX[i];
    if (vals.isEmpty) {
      print('${nkNames[i].padRight(14)} 0   ${rX.toStringAsFixed(1).padLeft(9)}  (no data)');
      continue;
    }
    final mean = vals.fold(0.0, (a, b) => a + b) / vals.length;
    double sdVal = 0.0;
    if (vals.length > 1) {
      final variance = vals.map((x) => (x - mean) * (x - mean)).fold(0.0, (a, b) => a + b) / (vals.length - 1);
      sdVal = variance > 0 ? _sqrt(variance) : 0.0;
    }
    final deltaMin = (mean - rX) * 60; // minutes difference for 24h NK
    final reliable = vals.length >= 3 && sdVal < 1.5;
    if (reliable) calibratedX[i] = mean;

    final flag = reliable ? ' ✓ USE' : '';
    print('${nkNames[i].padRight(14)} ${vals.length.toString().padLeft(2)}  '
          '${rX.toStringAsFixed(1).padLeft(9)}  '
          '${mean.toStringAsFixed(2).padLeft(10)}  '
          '${sdVal.toStringAsFixed(2).padLeft(6)}  '
          '${(deltaMin >= 0 ? "+" : "")}${deltaMin.toStringAsFixed(0).padLeft(4)} min$flag');
  }

  // Validation
  print('\n=== Validation (Di.Amrita, NK-match only) ===');
  final errR = <int>[], errC = <int>[];

  for (final e in entries) {
    final ourNkIdx0 = computeOurNkIdx0(e.date);
    if (ourNkIdx0 != e.nkIdx0) continue;

    final ss = SunriseSunset.computeNOAA(e.date, lat, lng);
    final sunrise = ss[0];
    final nkStartLon = e.nkIdx0 * nkSpan;
    final nkEndLon   = ((e.nkIdx0 + 1) % 27) * nkSpan;
    final nkEntry = bisectLon(from: sunrise.subtract(const Duration(hours: 48)), to: sunrise, targetLon: nkStartLon);
    final nkExit  = bisectLon(from: sunrise, to: sunrise.add(const Duration(hours: 48)), targetLon: nkEndLon);
    final nkDurHrs = nkExit.difference(nkEntry).inMinutes / 60.0;
    if (nkDurHrs < 15 || nkDurHrs > 30) continue;

    for (int pass = 0; pass < 2; pass++) {
      final x = pass == 0 ? ramakumarX[e.nkIdx0] : calibratedX[e.nkIdx0];
      final offsetMin = ((x / 24.0) * nkDurHrs * 60.0).round();
      final pred = nkEntry.add(Duration(minutes: offsetMin));
      int err = pred.difference(e.amritaTime).inMinutes.abs();
      (pass == 0 ? errR : errC).add(err);
    }
  }

  void stats(String label, List<int> errs) {
    if (errs.isEmpty) { print('$label: no data'); return; }
    final s = List.of(errs)..sort();
    final n = s.length;
    final mean = s.fold(0, (a, b) => a + b) / n;
    print('$label (n=$n)');
    print('  ≤5=${(s.where((e)=>e<=5).length/n*100).toStringAsFixed(1)}%'
          '  ≤15=${(s.where((e)=>e<=15).length/n*100).toStringAsFixed(1)}%'
          '  ≤30=${(s.where((e)=>e<=30).length/n*100).toStringAsFixed(1)}%'
          '  ≤60=${(s.where((e)=>e<=60).length/n*100).toStringAsFixed(1)}%'
          '  mean=${mean.toStringAsFixed(1)}m  median=${s[n~/2]}m');
  }

  stats('Ramakumar X', errR);
  stats('Calibrated X', errC);
}

double _sqrt(double x) {
  if (x <= 0) return 0;
  double r = x;
  for (int i = 0; i < 30; i++) r = (r + x / r) / 2;
  return r;
}
