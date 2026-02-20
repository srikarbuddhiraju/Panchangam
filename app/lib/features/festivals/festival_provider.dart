import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_provider.dart';
import 'festival_calculator.dart';
import 'festival_data.dart';

/// Provider that holds festival data for the current year.
///
/// Recomputes when the city (lat/lng) changes.
/// Uses a background isolate to avoid blocking the UI.
final festivalProvider = FutureProvider.autoDispose
    .family<Map<DateTime, List<Festival>>, int>((ref, year) async {
  final settings = ref.watch(settingsProvider);

  // Run in a separate isolate to avoid UI jank
  return compute(
    _computeFestivals,
    _FestivalParams(year: year, lat: settings.lat, lng: settings.lng),
  );
});

class _FestivalParams {
  final int year;
  final double lat;
  final double lng;
  const _FestivalParams({required this.year, required this.lat, required this.lng});
}

Map<DateTime, List<Festival>> _computeFestivals(_FestivalParams params) {
  return FestivalCalculator.computeYear(
    params.year,
    lat: params.lat,
    lng: params.lng,
  );
}
