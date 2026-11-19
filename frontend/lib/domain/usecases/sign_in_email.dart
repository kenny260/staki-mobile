import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repo);
  final AuthRepository _repo;
  Future<AppUser> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}
