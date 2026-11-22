import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/data/datasources/messaging_datasource.dart';
import 'package:staki_mobile/data/datasources/user_bootstrap_datasource.dart';
import 'package:staki_mobile/data/repositories/firebase_notification_repository.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/entities/push_message.dart';
import 'package:staki_mobile/domain/repositories/notification_repository.dart';
import 'package:staki_mobile/domain/usecases/disable_push_notifications.dart';
import 'package:staki_mobile/domain/usecases/enable_push_notifications.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirebaseNotificationRepository(
    MessagingDatasource(FirebaseMessaging.instance),
    UserBootstrapDatasource(ref.watch(firestoreProvider)),
  ),
);

final enablePushProvider = Provider(
  (ref) => EnablePushNotifications(ref.watch(notificationRepositoryProvider)),
);

final disablePushProvider = Provider(
  (ref) => DisablePushNotifications(ref.watch(notificationRepositoryProvider)),
);

/// Messages that arrive while the app is open.
final foregroundPushProvider = StreamProvider<PushMessage>(
  (ref) => ref.watch(notificationRepositoryProvider).foregroundMessages(),
);

/// Push is best effort: a failure here must never break sign-in.
Future<void> _bestEffort(Future<void> Function() action) async {
  try {
    await action();
  } on Object {
    // Ignored on purpose.
  }
}

/// Keeps this device's token saved on users/{uid} while someone is signed in
/// and verified. Read it once (see the router) and it stays alive.
final pushSyncProvider = Provider<void>((ref) {
  StreamSubscription<String>? refreshSub;
  ref.onDispose(() => refreshSub?.cancel());

  Future<void> enableWithRetry(String uid) async {
    // For a brand-new Google user, users/{uid} may not exist for a moment,
    // so retry a couple of times before giving up.
    for (final delay in const [
      Duration.zero,
      Duration(seconds: 3),
      Duration(seconds: 8),
    ]) {
      await Future<void>.delayed(delay);
      try {
        await ref.read(enablePushProvider)(uid);
        return;
      } on Object {
        // Try again.
      }
    }
  }

  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (previous, next) {
      final user = next.valueOrNull;
      if (user == null || !user.emailVerified) {
        unawaited(refreshSub?.cancel());
        refreshSub = null;
        return;
      }
      final before = previous?.valueOrNull;
      if (before != null && before.uid == user.uid && before.emailVerified) {
        return; // Same signed-in user, already handled.
      }

      unawaited(enableWithRetry(user.uid));
      unawaited(refreshSub?.cancel());
      final repo = ref.read(notificationRepositoryProvider);
      refreshSub = repo.tokenRefreshes().listen(
            (token) => unawaited(
              _bestEffort(() => repo.saveToken(user.uid, token)),
            ),
          );
    },
    fireImmediately: true,
  );
});
