import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper: theme, language, last role, notifications and
/// biometric unlock. Every value is read back on the next launch.
class PreferencesDatasource {
  PreferencesDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'theme_mode';
  static const _kLanguage = 'language_code';
  static const _kLastRole = 'last_role';
  static const _kNotifications = 'notifications_enabled';
  static const _kBiometrics = 'biometrics_enabled';

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

  /// Push and in-app notifications. On by default.
  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;

  Future<void> setNotificationsEnabled({required bool enabled}) =>
      _prefs.setBool(_kNotifications, enabled);

  /// Unlock with fingerprint or face instead of the PIN. On by default.
  bool get biometricsEnabled => _prefs.getBool(_kBiometrics) ?? true;

  Future<void> setBiometricsEnabled({required bool enabled}) =>
      _prefs.setBool(_kBiometrics, enabled);
}
