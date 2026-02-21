import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/calculations/eclipse.dart';

/// Eclipse data for a given year, computed in a background isolate.
final eclipseProvider =
    FutureProvider.autoDispose.family<List<EclipseData>, int>((ref, year) async {
  return compute(_findEclipses, year);
});

List<EclipseData> _findEclipses(int year) {
  return Eclipse.findInYear(year);
}

/// Eclipse on a specific date, or null if none. Reuses the year-level cache.
final eclipseForDateProvider =
    FutureProvider.autoDispose.family<EclipseData?, DateTime>((ref, date) async {
  final eclipses = await ref.watch(eclipseProvider(date.year).future);
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
