import 'package:staki_mobile/domain/entities/user_account.dart';
import 'package:staki_mobile/domain/repositories/user_repository.dart';

class GetUserAccount {
  const GetUserAccount(this._repo);
  final UserRepository _repo;

  Future<UserAccount?> call(String uid) => _repo.getAccount(uid);
}
