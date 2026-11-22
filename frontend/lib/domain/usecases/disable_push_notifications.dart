import 'package:staki_mobile/domain/repositories/notification_repository.dart';

/// Removes this device's token from the user, so a logged-out phone stops
/// receiving their notifications. Call it BEFORE signing out: the Firestore
/// rules only let the signed-in owner edit users/{uid}.
class DisablePushNotifications {
  const DisablePushNotifications(this._repo);
  final NotificationRepository _repo;

  Future<void> call(String uid) async {
    final token = await _repo.currentToken();
    if (token == null) return;
    await _repo.removeToken(uid, token);
  }
}
