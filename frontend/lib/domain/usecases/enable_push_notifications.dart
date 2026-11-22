import 'package:staki_mobile/domain/repositories/notification_repository.dart';

/// Asks for permission and saves this device's token for the user.
/// Does nothing if the user says no or the device has no token.
class EnablePushNotifications {
  const EnablePushNotifications(this._repo);
  final NotificationRepository _repo;

  Future<void> call(String uid) async {
    final allowed = await _repo.requestPermission();
    if (!allowed) return;
    final token = await _repo.currentToken();
    if (token == null) return;
    await _repo.saveToken(uid, token);
  }
}
