/// Festival date validation script — run with: dart run bin/validate_festivals.dart
/// Prints computed festival dates for 2025 and 2026.
/// Compare against Sringeri Panchangam / DrikPanchang to verify correctness.

import 'package:panchangam/features/festivals/festival_calculator.dart';

const double lat = 17.3850; // Hyderabad
const double lng = 78.4867;

void main() {
  for (final year in [2024, 2025, 2026]) {
    print('══════════════════════════════════════');
    print(' FESTIVALS $year');
    print('══════════════════════════════════════');

    final map = FestivalCalculator.computeYear(year, lat: lat, lng: lng);
    final sorted = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sorted) {
      final d = entry.key;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final names = entry.value.map((f) => f.nameEn).join(', ');
      print('  $dateStr  $names');
    }
    print('');
  }
}
