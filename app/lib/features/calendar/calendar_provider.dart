import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../../core/calculations/eclipse.dart';
import '../../features/festivals/festival_provider.dart';
import '../../features/eclipse/eclipse_provider.dart';
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
  final Map<DateTime, List<Festival>> festivals =
      ref.watch(festivalProvider(ym.year)).valueOrNull ?? {};

  // Overlay eclipse markers
  final List<EclipseData> eclipses =
      ref.watch(eclipseProvider(ym.year)).valueOrNull ?? [];

  return days.map((d) {
    final List<Festival> onDay = festivals[d.date] ?? [];
    final EclipseData? eclipse = eclipses.where((e) =>
        e.date.year == d.date.year &&
        e.date.month == d.date.month &&
        e.date.day == d.date.day).firstOrNull;

    if (onDay.isEmpty && eclipse == null) return d;

    return DayData(
      date: d.date,
      tithiNumber: d.tithiNumber,
      tithiNameTe: d.tithiNameTe,
      tithiNameEn: d.tithiNameEn,
      nakshatraNumber: d.nakshatraNumber,
      nakshatraNameTe: d.nakshatraNameTe,
      nakshatraNameEn: d.nakshatraNameEn,
      isFestival: onDay.isNotEmpty,
      festivalNamesTe: onDay.map((f) => f.nameTe).toList(),
      festivalNamesEn: onDay.map((f) => f.nameEn).toList(),
      hasEclipse: eclipse != null,
      eclipseNameTe: eclipse != null ? eclipse.type.nameTe : '',
      eclipseNameEn: eclipse != null ? eclipse.type.nameEn : '',
    );
  }).toList();
});
