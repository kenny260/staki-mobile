enum AuthFailureCode {
  emailInUse,
  invalidEmail,
  weakPassword,
  invalidCredentials,
  tooManyRequests,
  network,
  userDisabled,
  requiresRecentLogin,
  accountExistsWithDifferentCredential,
  cancelled,
  notSignedIn,
  unknown,
}

/// Pure Dart failure, safe to use in domain and presentation.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);
  final AuthFailureCode code;
  final String message;

  @override
  String toString() => message;
}
