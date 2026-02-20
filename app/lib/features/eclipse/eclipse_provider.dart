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
