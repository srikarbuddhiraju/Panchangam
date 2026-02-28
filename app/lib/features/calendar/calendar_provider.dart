import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../../core/calculations/eclipse.dart';
import '../../features/events/user_event_calculator.dart';
import '../../features/events/user_event_provider.dart';
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

  // Overlay festival markers — await so they are always present on first load
  final Map<DateTime, List<Festival>> festivals =
      await ref.watch(festivalProvider(ym.year).future);

  // Overlay eclipse markers — await so they are always present on first load
  final List<EclipseData> eclipses =
      await ref.watch(eclipseProvider(ym.year).future);

  // Overlay personal event markers (sync — already loaded from Hive)
  final bool isPremium = ref.watch(settingsProvider).isPremium;
  final List<UserTithiEvent> userEvents = isPremium
      ? ref.watch(userEventProvider.notifier).active
      : const [];

  return days.map((d) {
    final List<Festival> onDay = festivals[d.date] ?? [];
    final EclipseData? eclipse = eclipses
        .where((e) =>
            e.date.year == d.date.year &&
            e.date.month == d.date.month &&
            e.date.day == d.date.day)
        .firstOrNull;

    final List<String> personalNames =
        UserEventCalculator.namesForDay(userEvents, d);

    if (onDay.isEmpty && eclipse == null && personalNames.isEmpty) return d;

    return DayData(
      date: d.date,
      tithiNumber: d.tithiNumber,
      tithiNameTe: d.tithiNameTe,
      tithiNameEn: d.tithiNameEn,
      nakshatraNumber: d.nakshatraNumber,
      nakshatraNameTe: d.nakshatraNameTe,
      nakshatraNameEn: d.nakshatraNameEn,
      teluguMonthNumber: d.teluguMonthNumber,
      isAdhikaMaasa: d.isAdhikaMaasa,
      isFestival: onDay.isNotEmpty,
      festivalNamesTe: onDay.map((f) => f.nameTe).toList(),
      festivalNamesEn: onDay.map((f) => f.nameEn).toList(),
      hasEclipse: eclipse != null,
      eclipseNameTe: eclipse != null ? eclipse.type.nameTe : '',
      eclipseNameEn: eclipse != null ? eclipse.type.nameEn : '',
      hasPersonalEvent: personalNames.isNotEmpty,
      personalEventNames: personalNames,
    );
  }).toList();
});
