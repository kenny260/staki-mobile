import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';

// TODO(tolu): confirm the two home routes with Chris and Binthia.
const _lenderHome = '/marketplace';
const _borrowerHome = AppRoutes.creditPassport;

class AuthActionState {
  const AuthActionState({this.isLoading = false, this.failure});

  final bool isLoading;
  final AuthFailure? failure;
}

/// Pages call these methods and show `failure?.message`.
/// Pages navigate themselves after a success; the router redirect is the
/// safety net.
class AuthController extends StateNotifier<AuthActionState> {
  AuthController(this._ref) : super(const AuthActionState());

  final Ref _ref;

  Future<bool> _run(Future<void> Function() action) async {
    state = const AuthActionState(isLoading: true);
    try {
      await action();
      if (mounted) state = const AuthActionState();
      return true;
    } on AuthFailure catch (failure) {
      if (mounted) state = AuthActionState(failure: failure);
      return false;
    } on Object {
      if (mounted) {
        state = const AuthActionState(
          failure: AuthFailure(
            AuthFailureCode.unknown,
            'Something went wrong. Please try again.',
          ),
        );
      }
      return false;
    }
  }

  /// Creates users/{uid} with the role picked on A03. If there is no role
  /// and no document yet, the user must go back to role select, so sign out.
  Future<void> _bootstrap(AppUser user) async {
    try {
      final role = _ref.read(signUpRoleProvider);
      if (role != null) {
        await _ref.read(ensureUserDocumentProvider)(user, role: role);
        return;
      }
      final exists = await _ref.read(userRepositoryProvider).userExists(
            user.uid,
          );
      if (!exists) {
        throw const AuthFailure(
          AuthFailureCode.roleRequired,
          'Choose how you will use Staki first, then sign in.',
        );
      }
    } on AuthFailure {
      await _ref.read(signOutProvider)();
      rethrow;
    }
  }

  Future<bool> register(String email, String password) => _run(() async {
        final user = await _ref.read(registerEmailProvider)(email, password);
        await _bootstrap(user);
      });

  Future<bool> signIn(String email, String password) => _run(() async {
        final user = await _ref.read(signInEmailProvider)(email, password);
        await _bootstrap(user);
      });

  /// Returns false (and no failure) if the user closed the Google picker.
  Future<bool> signInWithGoogle() async {
    var signedIn = false;
    final ok = await _run(() async {
      final user = await _ref.read(signInGoogleProvider)();
      if (user == null) return;
      await _bootstrap(user);
      signedIn = true;
    });
    return ok && signedIn;
  }

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _ref.read(sendPasswordResetProvider)(email));

  Future<bool> resendVerification() =>
      _run(() => _ref.read(sendEmailVerificationProvider)());

  /// True once the user has tapped the link in the email.
  Future<bool> checkVerified() async {
    var verified = false;
    await _run(() async {
      verified = await _ref.read(checkEmailVerifiedProvider)();
    });
    // Re-read the user so the router sees emailVerified == true.
    if (verified && mounted) _ref.invalidate(authStateProvider);
    return verified;
  }

  /// Called by A09 "Account created" so a restart skips onboarding.
  Future<bool> completeOnboarding() => _run(() async {
        final user = _ref.read(authRepositoryProvider).currentUser;
        if (user == null) {
          throw const AuthFailure(
            AuthFailureCode.notSignedIn,
            'You are signed out.',
          );
        }
        await _ref.read(markOnboardingCompleteProvider)(user.uid);
      });

  /// Where the signed-in user belongs right now. Uses the current Firebase
  /// user directly, because the auth stream may not have emitted yet.
  Future<String> landingLocation() async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return AppRoutes.login;
    if (!user.emailVerified) return AppRoutes.verifyEmail;
    try {
      final account = await _ref.read(getUserAccountProvider)(user.uid);
      if (account == null) return AppRoutes.roleSelect;
      if (!account.onboardingComplete) return AppRoutes.phone;
      return account.role == 'lender' ? _lenderHome : _borrowerHome;
    } on AuthFailure {
      return AppRoutes.login;
    }
  }

  Future<bool> signOut() => _run(() => _ref.read(signOutProvider)());
}

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AuthActionState>(
  AuthController.new,
);
