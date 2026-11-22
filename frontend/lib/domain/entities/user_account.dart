/// What the router needs to know about a signed-in user's account.
class UserAccount {
  const UserAccount({required this.role, required this.onboardingComplete});

  /// 'borrower' or 'lender' (fixed once chosen).
  final String role;
  final bool onboardingComplete;
}
