import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_form_providers.dart';

void main() {
  group('AuthFormState', () {
    test('hides errors until submitted', () {
      const form = AuthFormState();

      expect(form.emailError, isNull);
      expect(form.newPasswordError, isNull);
    });

    test('shows errors after submitting an empty form', () {
      final form = const AuthFormState().copyWith(submitted: true);

      expect(form.emailError, isNotNull);
      expect(form.loginPasswordError, isNotNull);
      expect(form.newPasswordError, isNotNull);
    });

    test('loginValid needs an email and any password', () {
      final form =
          const AuthFormState().copyWith(email: 'a@b.com', password: 'x');

      expect(form.loginValid, isTrue);
    });

    test('registerValid needs a strong matching password', () {
      final weak = const AuthFormState().copyWith(
        email: 'a@b.com',
        password: 'short',
        confirmPassword: 'short',
      );
      final mismatch = const AuthFormState().copyWith(
        email: 'a@b.com',
        password: 'abcd1234',
        confirmPassword: 'abcd12345',
      );
      final good = const AuthFormState().copyWith(
        email: 'a@b.com',
        password: 'abcd1234',
        confirmPassword: 'abcd1234',
      );

      expect(weak.registerValid, isFalse);
      expect(mismatch.registerValid, isFalse);
      expect(good.registerValid, isTrue);
    });

    test('forgotValid only needs a valid email', () {
      expect(const AuthFormState().forgotValid, isFalse);
      expect(
        const AuthFormState().copyWith(email: 'a@b.com').forgotValid,
        isTrue,
      );
    });
  });
}
