import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../settings/settings_provider.dart';

/// Per-date Panchangam data provider.
/// Uses a family so each date has its own cached computation.
final panchangamForDateProvider = FutureProvider.autoDispose
    .family<PanchangamData, DateTime>((ref, date) async {
  final settings = ref.watch(settingsProvider);

  return compute(
    _computePanchangam,
    _Params(date: date, lat: settings.lat, lng: settings.lng,
        utcOffsetHours: settings.utcOffsetHours),
  );
});

class _Params {
  final DateTime date;
  final double lat;
  final double lng;
  final double utcOffsetHours;
  const _Params({required this.date, required this.lat, required this.lng,
      this.utcOffsetHours = 5.5});
}

PanchangamData _computePanchangam(_Params params) {
  return PanchangamEngine.compute(
    date: params.date,
    lat: params.lat,
    lng: params.lng,
    utcOffsetHours: params.utcOffsetHours,
  );
}
