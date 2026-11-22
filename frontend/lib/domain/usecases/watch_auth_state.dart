import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';

class WatchAuthState {
  const WatchAuthState(this._repo);
  final AuthRepository _repo;
  Stream<AppUser?> call() => _repo.authStateChanges();
}
