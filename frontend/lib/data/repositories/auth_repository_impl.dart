import 'package:firebase_auth/firebase_auth.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/data/datasources/firebase_auth_datasource.dart';
import 'package:staki_mobile/data/datasources/google_sign_in_datasource.dart';
import 'package:staki_mobile/data/models/app_user_model.dart';
import 'package:staki_mobile/data/repositories/auth_error_mapper.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._google);
  final FirebaseAuthDatasource _auth;
  final GoogleSignInDatasource _google;

  @override
  Stream<AppUser?> authStateChanges() => _auth
      .userChanges()
      .map((u) => u == null ? null : AppUserModel.fromFirebase(u));

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : AppUserModel.fromFirebase(u);
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) =>
      _guard(() async {
        final user = await _auth.register(email, password);
        await _auth.sendVerificationEmail();
        return AppUserModel.fromFirebase(user);
      });

  @override
  Future<AppUser> signInWithEmail(String email, String password) => _guard(
        () async =>
            AppUserModel.fromFirebase(await _auth.signIn(email, password)),
      );

  @override
  Future<AppUser?> signInWithGoogle() => _guard(() async {
        final cred = await _google.getCredential();
        if (cred == null) return null; // cancelled
        return AppUserModel.fromFirebase(
          await _auth.signInWithCredential(cred),
        );
      });

  /// Never reveals whether the email exists.
  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordReset(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return; // stay silent on purpose
      throw mapAuthError(e);
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  @override
  Future<void> resendVerificationEmail() => _guard(_auth.sendVerificationEmail);

  @override
  Future<bool> reloadAndCheckVerified() => _guard(() async {
        final u = await _auth.reload();
        if (u == null) {
          throw const AuthFailure(
            AuthFailureCode.notSignedIn,
            'You are signed out.',
          );
        }
        return u.emailVerified;
      });

  @override
  Future<void> signOut() => _guard(() async {
        await _google.signOut();
        await _auth.signOut();
      });
}
