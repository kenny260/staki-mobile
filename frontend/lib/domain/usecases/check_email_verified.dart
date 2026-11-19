import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class CheckEmailVerified {
  const CheckEmailVerified(this._repo);
  final AuthRepository _repo;
  Future<bool> call() => _repo.reloadAndCheckVerified();
}
