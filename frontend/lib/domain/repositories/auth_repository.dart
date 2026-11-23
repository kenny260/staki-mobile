import 'package:staki_mobile/domain/entities/app_user.dart';

abstract class AuthRepository {
  /// Emits on sign-in, sign-out AND when the user is reloaded
  /// (so emailVerified changes are picked up).
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> registerWithEmail(String email, String password);
  Future<AppUser> signInWithEmail(String email, String password);

  /// Returns null if the user cancelled the Google picker.
  Future<AppUser?> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  /// For email accounts: checks [currentPassword], then sets [newPassword].
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> resendVerificationEmail();
  Future<bool> reloadAndCheckVerified();
  Future<void> signOut();
}
