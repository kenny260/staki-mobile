import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repo);
  final AuthRepository _repo;
  Future<AppUser?> call() => _repo.signInWithGoogle();
}
