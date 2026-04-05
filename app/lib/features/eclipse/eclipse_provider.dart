import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/eclipse.dart';
import '../settings/settings_provider.dart';

/// Parameters for eclipse computation — year + user location.
class EclipseParams {
  final int year;
  final double lat;
  final double lng;
  final double utcOffsetHours;

  const EclipseParams({
    required this.year,
    required this.lat,
    required this.lng,
    required this.utcOffsetHours,
  });

  @override
  bool operator ==(Object other) =>
      other is EclipseParams &&
      other.year == year &&
      other.lat == lat &&
      other.lng == lng &&
      other.utcOffsetHours == utcOffsetHours;

  @override
  int get hashCode => Object.hash(year, lat, lng, utcOffsetHours);
}

/// Eclipse data for a given year + location, computed in a background isolate.
final eclipseProvider =
    FutureProvider.autoDispose.family<List<EclipseData>, EclipseParams>(
        (ref, params) async {
  return compute(_findEclipses, params);
});

List<EclipseData> _findEclipses(EclipseParams params) {
  return Eclipse.findInYear(
    params.year,
    lat: params.lat,
    lng: params.lng,
    utcOffsetHours: params.utcOffsetHours,
  );
}

/// Eclipse on a specific date, or null if none.
/// Reads location from settings and reuses the year-level cache.
final eclipseForDateProvider =
    FutureProvider.autoDispose.family<EclipseData?, DateTime>((ref, date) async {
  final settings = ref.watch(settingsProvider);
  final params = EclipseParams(
    year: date.year,
    lat: settings.lat,
    lng: settings.lng,
    utcOffsetHours: settings.utcOffsetHours,
  );
  final eclipses = await ref.watch(eclipseProvider(params).future);
  try {
    return eclipses.firstWhere(
      (e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day,
    );
  } catch (_) {
    return null;
  }
});
