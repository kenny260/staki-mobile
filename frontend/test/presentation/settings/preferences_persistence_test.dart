import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/domain/entities/user_role.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/features/settings/providers/settings_providers.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

ProviderContainer _container(SharedPreferences prefs) => ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('language survives an app restart', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = _container(prefs);
    expect(first.read(languageProvider), 'en');
    await first.read(languageProvider.notifier).set('fr');
    first.dispose();

    // "Restart": a brand-new container reading the same stored preferences.
    final second = _container(await SharedPreferences.getInstance());
    addTearDown(second.dispose);
    expect(second.read(languageProvider), 'fr');
    expect(supportedLanguages['fr'], 'Français');
  });

  test('theme mode survives an app restart', () async {
    final first = _container(await SharedPreferences.getInstance());
    await first.read(themeModeProvider.notifier).set(ThemeMode.dark);
    first.dispose();

    final second = _container(await SharedPreferences.getInstance());
    addTearDown(second.dispose);
    expect(second.read(themeModeProvider), ThemeMode.dark);
  });

  test('the last chosen role is remembered', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = _container(prefs);
    addTearDown(container.dispose);
    await container.read(selectedRoleProvider.notifier).select(UserRole.lender);
    expect(prefs.getString('last_role'), 'lender');
  });

  test('revoking MoMo access updates the permission state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(dataPermissionsProvider.notifier).setMomo(connected: true);
    expect(container.read(dataPermissionsProvider).momoConnected, isTrue);
    container.read(dataPermissionsProvider.notifier).setMomo(connected: false);
    expect(container.read(dataPermissionsProvider).momoConnected, isFalse);
  });
}
