import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/city_data.dart';

/// In-memory city search backed by a bundled JSON asset.
///
/// Must be initialized at app startup via [initialize(rootBundle)].
/// After that, [search] and [findByName] are synchronous.
class CityLookup {
  CityLookup._();

  static List<CityData> _cities = [];
  static bool _initialized = false;

  static const CityData defaultCity = CityData(
    name: 'Hyderabad',
    state: 'Telangana',
    lat: 17.3850,
    lng: 78.4867,
  );

  /// Load the city database from the bundled asset.
  /// Call once in main() before runApp().
  static Future<void> initialize(AssetBundle bundle) async {
    if (_initialized) return;
    try {
      final String json =
          await bundle.loadString('assets/data/cities_india.json');
      final List<dynamic> raw = jsonDecode(json) as List<dynamic>;
      _cities = raw
          .map((e) => CityData.fromJson(e as Map<String, dynamic>))
          .toList();
      _initialized = true;
    } catch (e) {
      // Fall back to an empty list with just the default city
      _cities = [defaultCity];
      _initialized = true;
    }
  }

  /// Search cities by name prefix, case-insensitive.
  /// Returns at most [limit] results (default 20).
  static List<CityData> search(String query, {int limit = 20}) {
    if (query.isEmpty) return _cities.take(limit).toList();
    final String q = query.toLowerCase().trim();
    return _cities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.state.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Find a city by exact name (case-insensitive).
  static CityData? findByName(String name) {
    final String n = name.toLowerCase();
    try {
      return _cities.firstWhere((c) => c.name.toLowerCase() == n);
    } catch (_) {
      return null;
    }
  }

  /// All loaded cities (for browsing).
  static List<CityData> get all => List.unmodifiable(_cities);

  /// Total number of cities in the database.
  static int get count => _cities.length;
}
