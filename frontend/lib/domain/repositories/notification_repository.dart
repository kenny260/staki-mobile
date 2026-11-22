import 'package:staki_mobile/domain/entities/push_message.dart';

abstract class NotificationRepository {
  /// Asks the user for permission. True when notifications are allowed.
  Future<bool> requestPermission();

  /// This device's FCM token, or null if it cannot get one (for example an
  /// emulator without Google Play).
  Future<String?> currentToken();

  Stream<String> tokenRefreshes();

  /// Messages that arrive while the app is open.
  Stream<PushMessage> foregroundMessages();

  /// The user tapped a notification while the app was in the background.
  Stream<PushMessage> openedMessages();

  /// The notification that launched the app from a closed state, if any.
  Future<PushMessage?> launchMessage();

  /// Stores the token on users/{uid}.fcmTokens.
  Future<void> saveToken(String uid, String token);

  Future<void> removeToken(String uid, String token);
}
