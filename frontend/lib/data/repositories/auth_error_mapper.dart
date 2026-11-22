import 'package:firebase_auth/firebase_auth.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';

AuthFailure mapAuthError(Object e) {
  if (e is AuthFailure) return e;
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthFailure(
          AuthFailureCode.emailInUse,
          'An account with this email already exists.',
        );
      case 'invalid-email':
        return const AuthFailure(
          AuthFailureCode.invalidEmail,
          'Enter a valid email address.',
        );
      case 'weak-password':
        return const AuthFailure(
          AuthFailureCode.weakPassword,
          'Password is too weak. Use at least 8 characters '
          'with a letter and a number.',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          AuthFailureCode.invalidCredentials,
          'Incorrect email or password.',
        );
      case 'user-disabled':
        return const AuthFailure(
          AuthFailureCode.userDisabled,
          'This account has been disabled.',
        );
      case 'too-many-requests':
        return const AuthFailure(
          AuthFailureCode.tooManyRequests,
          'Too many attempts. Please try again later.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          AuthFailureCode.network,
          'No internet connection.',
        );
      case 'requires-recent-login':
        return const AuthFailure(
          AuthFailureCode.requiresRecentLogin,
          'Please sign in again to continue.',
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          AuthFailureCode.accountExistsWithDifferentCredential,
          'This email is registered with a password. '
          'Sign in with your password instead.',
        );
    }
  }
  return const AuthFailure(
    AuthFailureCode.unknown,
    'Something went wrong. Please try again.',
  );
}
