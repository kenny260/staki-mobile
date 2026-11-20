import 'package:staki_mobile/domain/entities/app_user.dart';

abstract class UserRepository {
  /// Creates users/{uid} if it is missing. Returns true if it created it.
  Future<bool> ensureUserDocument(AppUser user, {required String role});

  Future<bool> userExists(String uid);
}
