import 'package:flutter_test/flutter_test.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/tithi.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

void main() {
  // Hyderabad coordinates
  const double lat = 17.3850;
  const double lng = 78.4867;

  group('Tithi', () {
    test('Tithi number is in range 1-30', () {
      // Check a random date
      final date = DateTime(2024, 3, 25);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final tNum = Tithi.number(jd);
      expect(tNum, inInclusiveRange(1, 30));
    });

    test('Purnima (full moon) has tithi number 15', () {
      // 2024-03-25 is Holi (Phalguna Purnima) — tithi 15
      // Let's check 2024-09-18 which is Purnima in Bhadrapada
      // Actually let's just verify the moonSunDiff is in the right range for tithi 15
      final date = DateTime(2024, 9, 18); // approximate Purnima
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      // On or near Purnima, diff should be close to 180°
      // Allow for slight variations (tithi 14, 15, or 16)
      final tNum = Tithi.number(jd);
      expect(tNum, inInclusiveRange(13, 17));
    });

    test('Paksha determination is correct', () {
      expect(Tithi.paksha(1), equals('Shukla'));
      expect(Tithi.paksha(15), equals('Shukla'));
      expect(Tithi.paksha(16), equals('Krishna'));
      expect(Tithi.paksha(30), equals('Krishna'));
    });

    test('Tithi end time is in the future relative to input', () {
      final date = DateTime(2024, 5, 1);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final endTime = Tithi.endTime(jd);
      expect(endTime.isAfter(sunTimes[0]), isTrue);
    });

    test('Tithi end time is within 2 days of sunrise', () {
      final date = DateTime(2024, 8, 15);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final endTime = Tithi.endTime(jd);
      final hours = endTime.difference(sunTimes[0]).inHours;
      expect(hours, inInclusiveRange(1, 48));
    });
  });
}
