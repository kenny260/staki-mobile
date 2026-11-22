import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this._repo);
  final AuthRepository _repo;
  Future<void> call(String email) => _repo.sendPasswordReset(email);
}
