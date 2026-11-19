import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/data/repositories/auth_error_mapper.dart';

void main() {
  group('mapAuthError', () {
    const expectedCodes = <String, AuthFailureCode>{
      'email-already-in-use': AuthFailureCode.emailInUse,
      'invalid-email': AuthFailureCode.invalidEmail,
      'weak-password': AuthFailureCode.weakPassword,
      'user-not-found': AuthFailureCode.invalidCredentials,
      'wrong-password': AuthFailureCode.invalidCredentials,
      'invalid-credential': AuthFailureCode.invalidCredentials,
      'user-disabled': AuthFailureCode.userDisabled,
      'too-many-requests': AuthFailureCode.tooManyRequests,
      'network-request-failed': AuthFailureCode.network,
      'requires-recent-login': AuthFailureCode.requiresRecentLogin,
      'account-exists-with-different-credential':
          AuthFailureCode.accountExistsWithDifferentCredential,
    };

    for (final entry in expectedCodes.entries) {
      test('maps ${entry.key} to ${entry.value.name}', () {
        final failure = mapAuthError(FirebaseAuthException(code: entry.key));

        expect(failure.code, entry.value);
        expect(failure.message, isNotEmpty);
      });
    }

    test('wrong password and unknown user give the same message', () {
      final wrongPassword = mapAuthError(
        FirebaseAuthException(code: 'wrong-password'),
      );
      final unknownUser = mapAuthError(
        FirebaseAuthException(code: 'user-not-found'),
      );

      expect(wrongPassword.message, unknownUser.message);
    });

    test('unrecognised Firebase code falls back to unknown', () {
      final failure = mapAuthError(FirebaseAuthException(code: 'something'));

      expect(failure.code, AuthFailureCode.unknown);
    });

    test('returns an existing AuthFailure unchanged', () {
      const original = AuthFailure(AuthFailureCode.network, 'Offline.');

      expect(mapAuthError(original), same(original));
    });

    test('maps non-Firebase errors to unknown', () {
      final failure = mapAuthError(StateError('boom'));

      expect(failure.code, AuthFailureCode.unknown);
    });
  });
}
