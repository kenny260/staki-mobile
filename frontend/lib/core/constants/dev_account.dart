/// Seeded demo borrower (see backend/seed/README.md). Fake data only.
///
/// TEMP: dev builds sign in with this account until the real login
/// screen exists. Staging and prod builds never use it.
abstract final class DevAccount {
  static const String email = 'borrower@staki.demo';
  static const String password = 'StakiDemo123!';
}
