import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/data/datasources/preferences_datasource.dart';

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final preferencesProvider = Provider<PreferencesDatasource>(
  (ref) => PreferencesDatasource(ref.watch(sharedPreferencesProvider)),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(preferencesProvider).setThemeMode(mode);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => ref.read(preferencesProvider).languageCode;

  Future<void> set(String code) async {
    state = code;
    await ref.read(preferencesProvider).setLanguageCode(code);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).notificationsEnabled;

  Future<void> set({required bool enabled}) async {
    state = enabled;
    await ref.read(preferencesProvider).setNotificationsEnabled(
          enabled: enabled,
        );
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsNotifier, bool>(NotificationsNotifier.new);

class BiometricsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).biometricsEnabled;

  Future<void> set({required bool enabled}) async {
    state = enabled;
    await ref.read(preferencesProvider).setBiometricsEnabled(enabled: enabled);
  }
}

final biometricsEnabledProvider =
    NotifierProvider<BiometricsNotifier, bool>(BiometricsNotifier.new);
