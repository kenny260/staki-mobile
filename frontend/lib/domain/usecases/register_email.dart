import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  const RegisterWithEmail(this._repo);
  final AuthRepository _repo;
  Future<AppUser> call(String email, String password) =>
      _repo.registerWithEmail(email, password);
}
