/// compute_ml_features.dart
///
/// Reads amrita CSV files (from parse_amrita_ocr.py / parse_amrita_2627.py)
/// and computes astronomical ML features for each entry:
///   - moon_speed_dph     : Moon's angular speed in degrees/hour at amrita time
///   - nk_duration_min    : how many minutes Moon spends in this nakshatra
///   - nk_entry_lon       : start longitude of the nakshatra (0, 13.333, 26.666, ...)
///   - moon_lon_at_amrita : Moon sidereal longitude at amrita start time
///   - lon_frac           : fraction (0-1) through nakshatra span at amrita
///   - time_since_nk_entry_min : minutes elapsed since Moon entered the nakshatra
///   - time_frac          : lon_frac proxy (same calculation)
///   - amrita_offset_min  : minutes from midnight (IST) of amrita start
///   - sunrise_min        : minutes from midnight (IST) of local sunrise
///   - month_group        : YYYY-MM for leave-one-month-out CV
///
/// Usage:
///   dart run bin/compute_ml_features.dart \
///     docs/data/amrita_2526.csv docs/data/amrita_2627.csv \
///     docs/data/ml_features.csv
///
/// Or just one file:
///   dart run bin/compute_ml_features.dart docs/data/amrita_2526.csv - docs/data/ml_features.csv
///
import 'dart:io';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/lunar_position.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

// Sringeri coordinates for sunrise (used as reference location)
const double lat = 13.9299;
const double lng = 75.6350;
const double nkSpan = 360.0 / 27; // ~13.333°

/// Parse HH:MM string to minutes from midnight
int parseHHMM(String s) {
  final parts = s.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// Moon speed in degrees per hour at a given Julian Day (finite difference, 1h)
double moonSpeedDPH(double jd) {
  final lon1 = LunarPosition.siderealLongitude(jd);
  final lon2 = LunarPosition.siderealLongitude(jd + 1.0 / 24.0);
  double diff = lon2 - lon1;
  if (diff < 0) diff += 360.0; // handle wraparound near 360°/0°
  return diff;
}

/// Find when Moon entered the current nakshatra by stepping backward
/// Returns the DateTime when Moon crossed the nakshatra boundary
DateTime nkEntryTime(double jdAmrita) {
  final int nkNum = Nakshatra.number(jdAmrita);
  final double nkStartLon = (nkNum - 1) * nkSpan;

  // Step back in 10-minute increments until Moon was in previous nakshatra
  double jd = jdAmrita;
  for (int i = 0; i < 200; i++) {
    // 10 min = 10/1440 days
    jd -= 10.0 / 1440.0;
    final lon = LunarPosition.siderealLongitude(jd);
    // Check if Moon has crossed the nakshatra entry boundary
    // Handle wraparound (Revati/Ashwini boundary at 0°)
    double relLon = (lon - nkStartLon + 360) % 360;
    if (relLon > nkSpan + 1.0) {
      // We've gone past the entry — binary search to refine
      double jdLo = jd;
      double jdHi = jd + 10.0 / 1440.0;
      for (int j = 0; j < 30; j++) {
        final jdMid = (jdLo + jdHi) / 2;
        final lonMid = LunarPosition.siderealLongitude(jdMid);
        final relMid = (lonMid - nkStartLon + 360) % 360;
        if (relMid > nkSpan) {
          jdLo = jdMid;
        } else {
          jdHi = jdMid;
        }
      }
      return JulianDay.toIST((jdLo + jdHi) / 2);
    }
  }
  // Fallback: return 27h before amrita (Moon can't stay in one nk > 27h)
  return JulianDay.toIST(jdAmrita - 27.0 / 24.0);
}

void main(List<String> args) {
  if (args.length < 3) {
    print('Usage: dart run bin/compute_ml_features.dart <csv1> <csv2|--> <output_csv>');
    exit(1);
  }

  final csvFiles = [args[0]];
  if (args[1] != '-' && args[1] != '--') csvFiles.add(args[1]);
  final outputPath = args[2];

  final allRows = <List<String>>[];

  // Header
  allRows.add([
    'date', 'nk_name', 'nk_idx', 'amrita_type',
    'amrita_start', 'amrita_offset_min',
    'moon_lon_at_amrita', 'moon_speed_dph',
    'nk_entry_lon', 'lon_frac',
    'nk_duration_min', 'time_since_nk_entry_min', 'time_frac',
    'sunrise_min', 'month_group',
  ]);

  int totalProcessed = 0;
  int totalSkipped = 0;

  for (final csvPath in csvFiles) {
    final file = File(csvPath);
    if (!file.existsSync()) {
      stderr.writeln('File not found: $csvPath, skipping');
      continue;
    }

    final lines = file.readAsLinesSync();
    if (lines.isEmpty) continue;

    // Skip header
    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',');
      if (cols.length < 5) continue;

      final dateStr = cols[0].trim();     // YYYY-MM-DD
      final nkName  = cols[1].trim();
      final nkIdx   = int.tryParse(cols[2].trim()) ?? -1;
      final aType   = cols[3].trim();     // Di or Ra
      final aTime   = cols[4].trim();     // HH:MM

      if (nkIdx < 0) {
        totalSkipped++;
        continue;
      }

      // Parse date and time → DateTime (IST)
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) { totalSkipped++; continue; }
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final amritaMin = parseHHMM(aTime);
      final amritaHour = amritaMin ~/ 60;
      final amritaMinute = amritaMin % 60;

      final amritaDT = DateTime(year, month, day, amritaHour, amritaMinute);
      final jdAmrita = JulianDay.fromIST(amritaDT);

      // Compute features
      try {
        final moonLon = LunarPosition.siderealLongitude(jdAmrita);
        final speed = moonSpeedDPH(jdAmrita);

        final nkNum = Nakshatra.number(jdAmrita);
        final nkStartLon = (nkNum - 1) * nkSpan;
        double lonFrac = ((moonLon - nkStartLon) % 360) / nkSpan;
        if (lonFrac < 0) lonFrac += 1.0;
        lonFrac = lonFrac.clamp(0.0, 1.0);

        // Nakshatra end time → duration from entry
        final nkEnd = Nakshatra.endTime(jdAmrita);
        final jdNkEnd = JulianDay.fromIST(nkEnd);

        // Nakshatra entry time (step backward)
        final nkEntry = nkEntryTime(jdAmrita);
        final jdNkEntry = JulianDay.fromIST(nkEntry);

        final nkDurationMin = ((jdNkEnd - jdNkEntry) * 1440).round();
        final timeSinceEntryMin = ((jdAmrita - jdNkEntry) * 1440).round();
        final timeFrac = nkDurationMin > 0
            ? (timeSinceEntryMin / nkDurationMin).clamp(0.0, 1.0)
            : lonFrac;

        // Sunrise
        final date = DateTime(year, month, day);
        final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
        final sunriseMin = sunTimes[0].hour * 60 + sunTimes[0].minute;

        final monthGroup = '$year-${month.toString().padLeft(2,'0')}';

        allRows.add([
          dateStr, nkName, '$nkIdx', aType,
          aTime, '$amritaMin',
          moonLon.toStringAsFixed(4),
          speed.toStringAsFixed(4),
          nkStartLon.toStringAsFixed(4),
          lonFrac.toStringAsFixed(4),
          '$nkDurationMin',
          '$timeSinceEntryMin',
          timeFrac.toStringAsFixed(4),
          '$sunriseMin',
          monthGroup,
        ]);
        totalProcessed++;

        if (totalProcessed % 50 == 0) {
          stderr.writeln('  processed $totalProcessed entries...');
        }
      } catch (e) {
        stderr.writeln('  Error on $dateStr $aTime: $e');
        totalSkipped++;
      }
    }
  }

  // Write output CSV
  final out = File(outputPath);
  out.writeAsStringSync(allRows.map((r) => r.join(',')).join('\n') + '\n');

  stderr.writeln('Done: $totalProcessed entries → $outputPath ($totalSkipped skipped)');
  print('Output: $outputPath');
}
