import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_form_providers.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

Future<ProviderContainer> _container(Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('login starts empty when nobody has logged in yet', () async {
    final container = await _container({});
    expect(container.read(loginFormProvider).email, '');
  });

  test('login starts with the last email that logged in', () async {
    final container =
        await _container({'last_login_email': 'borrower@staki.demo'});
    expect(container.read(loginFormProvider).email, 'borrower@staki.demo');
    // Only the email is prefilled, never a password.
    expect(container.read(loginFormProvider).password, '');
  });

  test('the saved email is trimmed and read back', () async {
    final container = await _container({});
    await container
        .read(preferencesProvider)
        .setLastLoginEmail('  lender@staki.demo ');
    expect(
      container.read(preferencesProvider).lastLoginEmail,
      'lender@staki.demo',
    );
  });

  test('without SharedPreferences the login form still works', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(loginFormProvider).email, '');
  });
}
