import 'package:flutter_test/flutter_test.dart';
import 'package:panchangam/core/calculations/julian_day.dart';

void main() {
  group('JulianDay', () {
    test('J2000.0 = 2451545.0', () {
      // Jan 1.5, 2000 UT (noon on Jan 1, 2000)
      final double jd = JulianDay.fromDateTime(2000, 1, 1, 12, 0, 0);
      expect(jd, closeTo(2451545.0, 0.0001));
    });

    test('J1900.0 — Jan 1 noon 1900 UT = 2415021.0', () {
      // JD epoch: J1900.0 = Jan 0.5 TT 1900 = JD 2415020.0
      // Jan 1 noon 1900 = JD 2415021.0 (one full day later)
      final double jd = JulianDay.fromDateTime(1900, 1, 1, 12, 0, 0);
      expect(jd, closeTo(2415021.0, 0.01));
    });

    test('2024-01-01 00:00 UT round-trips correctly', () {
      final double jd = JulianDay.fromDateTime(2024, 1, 1, 0, 0, 0);
      final DateTime output = JulianDay.toUTC(jd);
      expect(output.year, equals(2024));
      expect(output.month, equals(1));
      expect(output.day, equals(1));
    });

    test('normalize360 keeps values in [0, 360)', () {
      expect(JulianDay.normalize360(-10), closeTo(350, 0.001));
      expect(JulianDay.normalize360(370), closeTo(10, 0.001));
      expect(JulianDay.normalize360(0), closeTo(0, 0.001));
      expect(JulianDay.normalize360(360), closeTo(0, 0.001));
    });

    test('IST offset round-trip', () {
      final DateTime ist = DateTime(2024, 3, 15, 6, 0, 0); // 6 AM IST
      final double jd = JulianDay.fromIST(ist);
      final DateTime backToIST = JulianDay.toIST(jd);
      expect(backToIST.hour, equals(6));
      expect(backToIST.minute, equals(0));
    });
  });
}
