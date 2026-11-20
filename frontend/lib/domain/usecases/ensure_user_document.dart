import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/user_repository.dart';

class EnsureUserDocument {
  const EnsureUserDocument(this._repo);
  final UserRepository _repo;

  Future<bool> call(AppUser user, {required String role}) =>
      _repo.ensureUserDocument(user, role: role);
}
