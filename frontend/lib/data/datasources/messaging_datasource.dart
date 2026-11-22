// ignore_for_file: deprecated_member_use
import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper over FirebaseMessaging.
class MessagingDatasource {
  MessagingDatasource(this._messaging);
  final FirebaseMessaging _messaging;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}

/// Runs when a message arrives while the app is in the background or closed.
/// It must be a top-level function. Notification messages are shown by the
/// system on their own, so there is nothing to do here for the demo.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
