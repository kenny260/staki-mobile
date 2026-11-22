import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/data/datasources/user_bootstrap_datasource.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/entities/user_account.dart';
import 'package:staki_mobile/domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._datasource);
  final UserBootstrapDatasource _datasource;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException {
      throw const AuthFailure(
        AuthFailureCode.unknown,
        'We could not set up your account. Please try again.',
      );
    }
  }

  @override
  Future<bool> ensureUserDocument(AppUser user, {required String role}) =>
      _guard(() => _datasource.ensureUserDocument(user, role: role));

  @override
  Future<bool> userExists(String uid) =>
      _guard(() => _datasource.userExists(uid));

  @override
  Future<UserAccount?> getAccount(String uid) => _guard(() async {
        final data = await _datasource.getUser(uid);
        if (data == null) return null;
        return UserAccount(
          role: data['role'] as String? ?? '',
          onboardingComplete: data['onboardingComplete'] == true,
        );
      });

  @override
  Future<void> markOnboardingComplete(String uid) =>
      _guard(() => _datasource.markOnboardingComplete(uid));
}
