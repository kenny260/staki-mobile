import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class ResendVerificationEmail {
  const ResendVerificationEmail(this._repo);
  final AuthRepository _repo;
  Future<void> call() => _repo.resendVerificationEmail();
}
