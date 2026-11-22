import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:staki_mobile/data/datasources/messaging_datasource.dart';
import 'package:staki_mobile/data/datasources/user_bootstrap_datasource.dart';
import 'package:staki_mobile/domain/entities/push_message.dart';
import 'package:staki_mobile/domain/repositories/notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(this._messaging, this._users);

  final MessagingDatasource _messaging;
  final UserBootstrapDatasource _users;

  PushMessage _toMessage(RemoteMessage message) => PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        route: message.data['route'] as String?,
      );

  @override
  Future<bool> requestPermission() => _messaging.requestPermission();

  @override
  Future<String?> currentToken() async {
    try {
      return await _messaging.getToken();
    } on FirebaseException {
      // No Google Play services (some emulators) or no network.
      return null;
    }
  }

  @override
  Stream<String> tokenRefreshes() => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> foregroundMessages() =>
      _messaging.onMessage.map(_toMessage);

  @override
  Stream<PushMessage> openedMessages() =>
      _messaging.onMessageOpenedApp.map(_toMessage);

  @override
  Future<PushMessage?> launchMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toMessage(message);
  }

  @override
  Future<void> saveToken(String uid, String token) =>
      _users.addFcmToken(uid, token);

  @override
  Future<void> removeToken(String uid, String token) =>
      _users.removeFcmToken(uid, token);
}
