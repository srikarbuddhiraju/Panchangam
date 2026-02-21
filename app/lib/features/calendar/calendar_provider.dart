import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../../features/festivals/festival_provider.dart';
import '../../features/festivals/festival_data.dart';
import '../settings/settings_provider.dart';

/// The currently displayed month (year, month) in the calendar.
final displayedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

/// DayData list for a specific year+month, computed in a background isolate.
final monthDataProvider = FutureProvider
    .family<List<DayData>, ({int year, int month})>((ref, ym) async {
  final settings = ref.watch(settingsProvider);

  final List<DayData> days = await compute(
    computeMonthData,
    MonthComputeParams(
      year: ym.year,
      month: ym.month,
      lat: settings.lat,
      lng: settings.lng,
    ),
  );

  // Overlay festival markers
  final festivalsAsync = ref.watch(festivalProvider(ym.year));
  final Map<DateTime, List<Festival>> festivals =
      festivalsAsync.valueOrNull ?? {};

  return days.map((d) {
    final List<Festival> onDay = festivals[d.date] ?? [];
    if (onDay.isEmpty) return d;
    return DayData(
      date: d.date,
      tithiNumber: d.tithiNumber,
      tithiNameTe: d.tithiNameTe,
      tithiNameEn: d.tithiNameEn,
      nakshatraNumber: d.nakshatraNumber,
      nakshatraNameTe: d.nakshatraNameTe,
      nakshatraNameEn: d.nakshatraNameEn,
      isFestival: true,
      festivalNamesTe: onDay.map((f) => f.nameTe).toList(),
      festivalNamesEn: onDay.map((f) => f.nameEn).toList(),
    );
  }).toList();
});
