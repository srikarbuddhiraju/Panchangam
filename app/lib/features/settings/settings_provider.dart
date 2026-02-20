import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/city_lookup/models/city_data.dart';
import '../../core/utils/hive_keys.dart';
import '../../core/utils/app_strings.dart';

/// Current app settings — immutable snapshot.
class AppSettings {
  final String cityName;
  final double lat;
  final double lng;
  final AppLanguage language;
  final ThemeMode themeMode;
  final bool use24h;

  const AppSettings({
    required this.cityName,
    required this.lat,
    required this.lng,
    required this.language,
    required this.themeMode,
    required this.use24h,
  });

  CityData get city => CityData(
        name: cityName,
        state: '',
        lat: lat,
        lng: lng,
      );

  AppSettings copyWith({
    String? cityName,
    double? lat,
    double? lng,
    AppLanguage? language,
    ThemeMode? themeMode,
    bool? use24h,
  }) =>
      AppSettings(
        cityName: cityName ?? this.cityName,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        use24h: use24h ?? this.use24h,
      );
}

/// Riverpod notifier that persists settings to Hive.
///
/// The Hive box 'settings' must be opened before this is first accessed.
/// Do that in main() with: await Hive.openBox(HiveKeys.settingsBox);
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final Box box = Hive.box(HiveKeys.settingsBox);
    final String lang = box.get(HiveKeys.language, defaultValue: 'te') as String;
    final AppLanguage language =
        lang == 'te' ? AppLanguage.telugu : AppLanguage.english;

    final String themeName =
        box.get(HiveKeys.themeMode, defaultValue: 'system') as String;
    final ThemeMode themeMode = ThemeMode.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeMode.system,
    );

    // Apply language globally
    S.setLanguage(language);

    return AppSettings(
      cityName:
          box.get(HiveKeys.city, defaultValue: 'Hyderabad') as String,
      lat: (box.get(HiveKeys.latitude, defaultValue: 17.3850) as num)
          .toDouble(),
      lng: (box.get(HiveKeys.longitude, defaultValue: 78.4867) as num)
          .toDouble(),
      language: language,
      themeMode: themeMode,
      use24h:
          box.get(HiveKeys.timeFormat, defaultValue: '12h') as String == '24h',
    );
  }

  Future<void> setCity(CityData city) async {
    final Box box = Hive.box(HiveKeys.settingsBox);
    await box.put(HiveKeys.city, city.name);
    await box.put(HiveKeys.latitude, city.lat);
    await box.put(HiveKeys.longitude, city.lng);
    state = state.copyWith(
      cityName: city.name,
      lat: city.lat,
      lng: city.lng,
    );
  }

  Future<void> setLanguage(AppLanguage lang) async {
    final Box box = Hive.box(HiveKeys.settingsBox);
    await box.put(HiveKeys.language, lang == AppLanguage.telugu ? 'te' : 'en');
    S.setLanguage(lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final Box box = Hive.box(HiveKeys.settingsBox);
    await box.put(HiveKeys.themeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setTimeFormat(bool use24h) async {
    final Box box = Hive.box(HiveKeys.settingsBox);
    await box.put(HiveKeys.timeFormat, use24h ? '24h' : '12h');
    state = state.copyWith(use24h: use24h);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
