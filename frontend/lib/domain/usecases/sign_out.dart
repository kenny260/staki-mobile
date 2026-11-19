import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class SignOut {
  const SignOut(this._repo);
  final AuthRepository _repo;
  Future<void> call() => _repo.signOut();
}
