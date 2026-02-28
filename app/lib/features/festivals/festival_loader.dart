import 'dart:convert';
import 'package:flutter/services.dart';
import 'festival_data.dart';

/// Loads the festival list from the bundled JSON asset.
///
/// Call [FestivalLoader.initialize] once at app start (in main()).
/// After that, [FestivalLoader.all] returns the full list synchronously.
///
/// JSON schema (assets/data/festivals.json):
/// {
///   "version": 1,
///   "festivals": [
///     { "nameTe": "...", "nameEn": "...", "type": "tithi"|"solar",
///       "paksha": 1|2, "tithi": 1-15, "teluguMonth": 1-12 (optional),
///       "gregorianMonth": 1-12 (solar), "gregorianDay": 1-31 (solar),
///       "observedAtNight": false, "descriptionEn": "...", "icon": "..." }
///   ]
/// }
class FestivalLoader {
  FestivalLoader._();

  static List<Festival> _festivals = [];

  /// All loaded festivals. Empty until [initialize] is called.
  static List<Festival> get all => _festivals;

  /// Parse and cache the festival JSON asset.
  /// Must be called after [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> initialize(AssetBundle bundle) async {
    final String raw =
        await bundle.loadString('assets/data/festivals.json');
    final Map<String, dynamic> json =
        jsonDecode(raw) as Map<String, dynamic>;

    final List<dynamic> items = json['festivals'] as List<dynamic>;
    _festivals = items.map(_fromJson).toList();
  }

  static Festival _fromJson(dynamic item) {
    final Map<String, dynamic> m = item as Map<String, dynamic>;

    final FestivalType type = m['type'] == 'solar'
        ? FestivalType.solar
        : FestivalType.tithi;

    return Festival(
      nameTe: m['nameTe'] as String,
      nameEn: m['nameEn'] as String,
      type: type,
      paksha: m['paksha'] as int?,
      tithi: m['tithi'] as int?,
      teluguMonth: m['teluguMonth'] as int?,
      gregorianMonth: m['gregorianMonth'] as int?,
      gregorianDay: m['gregorianDay'] as int?,
      observedAtNight: (m['observedAtNight'] as bool?) ?? false,
      descriptionEn: (m['descriptionEn'] as String?) ?? '',
      icon: m['icon'] as String?,
    );
  }
}
