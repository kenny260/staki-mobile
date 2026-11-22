import 'package:staki_mobile/domain/repositories/user_repository.dart';

class MarkOnboardingComplete {
  const MarkOnboardingComplete(this._repo);
  final UserRepository _repo;

  Future<void> call(String uid) => _repo.markOnboardingComplete(uid);
}
