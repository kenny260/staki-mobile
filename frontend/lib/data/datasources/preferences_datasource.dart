import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper: theme, language, last role (rubric item).
class PreferencesDatasource {
  PreferencesDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'theme_mode';
  static const _kLanguage = 'language_code';
  static const _kLastRole = 'last_role';

  ThemeMode get themeMode {
    final saved = _prefs.getString(_kTheme);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kTheme, mode.name);

  /// 'en', 'rw' or 'fr'.
  String get languageCode => _prefs.getString(_kLanguage) ?? 'en';

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguage, code);

  String? get lastRole => _prefs.getString(_kLastRole);

  Future<void> setLastRole(String role) => _prefs.setString(_kLastRole, role);
}
