import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class ChangePassword {
  const ChangePassword(this._repo);
  final AuthRepository _repo;
  Future<void> call(String currentPassword, String newPassword) =>
      _repo.changePassword(currentPassword, newPassword);
}
