import 'package:flutter_test/flutter_test.dart';
import 'package:panchangam/core/calculations/julian_day.dart';
import 'package:panchangam/core/calculations/nakshatra.dart';
import 'package:panchangam/core/calculations/sunrise_sunset.dart';

void main() {
  const double lat = 17.3850;
  const double lng = 78.4867;

  group('Nakshatra', () {
    test('Nakshatra number is in range 1-27', () {
      final date = DateTime(2024, 6, 15);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final nNum = Nakshatra.number(jd);
      expect(nNum, inInclusiveRange(1, 27));
    });

    test('Pada is in range 1-4', () {
      final date = DateTime(2024, 6, 15);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final pada = Nakshatra.pada(jd);
      expect(pada, inInclusiveRange(1, 4));
    });

    test('Nakshatra end time is after sunrise', () {
      final date = DateTime(2024, 4, 14);
      final sunTimes = SunriseSunset.computeNOAA(date, lat, lng);
      final jd = JulianDay.fromIST(sunTimes[0]);
      final endTime = Nakshatra.endTime(jd);
      expect(endTime.isAfter(sunTimes[0]), isTrue);
    });

    test('27 nakshatra names are defined in Telugu', () {
      expect(Nakshatra.namesTe.length, equals(27));
    });

    test('27 nakshatra names are defined in English', () {
      expect(Nakshatra.namesEn.length, equals(27));
    });

    test('Name index matches number', () {
      expect(Nakshatra.namesTe[0], equals('అశ్వని'));
      expect(Nakshatra.namesEn[26], equals('Revati'));
    });
  });
}
