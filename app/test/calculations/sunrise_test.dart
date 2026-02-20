import 'package:flutter_test/flutter_test.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

void main() {
  // Hyderabad: lat=17.385, lng=78.4867
  // Reference: drikpanchang.com for Hyderabad
  const double lat = 17.3850;
  const double lng = 78.4867;

  group('SunriseSunset — Hyderabad', () {
    test('2024-01-14 (Makar Sankranti) sunrise ~6:49 AM IST', () {
      final date = DateTime(2024, 1, 14);
      final times = SunriseSunset.computeNOAA(date, lat, lng);
      final sunrise = times[0];
      // drikpanchang shows ~6:49 AM IST on 14 Jan 2024 for Hyderabad
      // Allow ±8 minutes
      expect(sunrise.hour, equals(6));
      expect(sunrise.minute, inInclusiveRange(41, 57));
    });

    test('2024-06-21 (summer solstice) sunrise ~5:45 AM IST', () {
      final date = DateTime(2024, 6, 21);
      final times = SunriseSunset.computeNOAA(date, lat, lng);
      final sunrise = times[0];
      // drikpanchang: ~5:43–5:47 AM
      expect(sunrise.hour, equals(5));
      expect(sunrise.minute, inInclusiveRange(40, 52));
    });

    test('2024-12-21 (winter solstice) sunrise ~6:41 AM IST', () {
      final date = DateTime(2024, 12, 21);
      final times = SunriseSunset.computeNOAA(date, lat, lng);
      final sunrise = times[0];
      // NOAA algorithm gives ~6:41 AM; drikpanchang shows ~6:47 (±6 min offset)
      expect(sunrise.hour, equals(6));
      expect(sunrise.minute, inInclusiveRange(38, 50));
    });

    test('sunrise always before sunset', () {
      final date = DateTime(2024, 5, 10);
      final times = SunriseSunset.computeNOAA(date, lat, lng);
      expect(times[0].isBefore(times[1]), isTrue);
    });

    test('day length is reasonable (9–15 hours at Hyderabad)', () {
      final date = DateTime(2024, 7, 15);
      final times = SunriseSunset.computeNOAA(date, lat, lng);
      final dayMinutes = times[1].difference(times[0]).inMinutes;
      expect(dayMinutes, inInclusiveRange(9 * 60, 15 * 60));
    });
  });
}
