import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/domain/repositories/notification_repository.dart';
import 'package:staki_mobile/domain/usecases/disable_push_notifications.dart';
import 'package:staki_mobile/domain/usecases/enable_push_notifications.dart';

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late _MockNotificationRepository repo;

  setUp(() => repo = _MockNotificationRepository());

  group('EnablePushNotifications', () {
    test('saves the token when permission is granted', () async {
      when(() => repo.requestPermission()).thenAnswer((_) async => true);
      when(() => repo.currentToken()).thenAnswer((_) async => 'tok');
      when(() => repo.saveToken('u1', 'tok')).thenAnswer((_) async {});

      await EnablePushNotifications(repo)('u1');

      verify(() => repo.saveToken('u1', 'tok')).called(1);
    });

    test('does nothing when permission is denied', () async {
      when(() => repo.requestPermission()).thenAnswer((_) async => false);

      await EnablePushNotifications(repo)('u1');

      verifyNever(() => repo.saveToken(any(), any()));
    });

    test('does nothing when the device has no token', () async {
      when(() => repo.requestPermission()).thenAnswer((_) async => true);
      when(() => repo.currentToken()).thenAnswer((_) async => null);

      await EnablePushNotifications(repo)('u1');

      verifyNever(() => repo.saveToken(any(), any()));
    });
  });

  group('DisablePushNotifications', () {
    test('removes the token', () async {
      when(() => repo.currentToken()).thenAnswer((_) async => 'tok');
      when(() => repo.removeToken('u1', 'tok')).thenAnswer((_) async {});

      await DisablePushNotifications(repo)('u1');

      verify(() => repo.removeToken('u1', 'tok')).called(1);
    });

    test('does nothing without a token', () async {
      when(() => repo.currentToken()).thenAnswer((_) async => null);

      await DisablePushNotifications(repo)('u1');

      verifyNever(() => repo.removeToken(any(), any()));
    });
  });
}
