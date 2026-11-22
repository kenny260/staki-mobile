class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.provider,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  /// 'password' or 'google.com'
  final String provider;

  bool get isGoogle => provider == 'google.com';
}
