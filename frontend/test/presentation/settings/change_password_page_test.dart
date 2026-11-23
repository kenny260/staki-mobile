import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';
import 'package:staki_mobile/domain/usecases/change_password.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s07_change_password_page.dart';

/// Only changePassword is used by this screen.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.currentPassword);

  String currentPassword;
  final calls = <(String, String)>[];

  @override
  Future<void> changePassword(String current, String next) async {
    calls.add((current, next));
    if (current != currentPassword) {
      throw const AuthFailure(
        AuthFailureCode.invalidCredentials,
        'Your current password is incorrect.',
      );
    }
    currentPassword = next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppUser _user({String provider = 'password'}) => AppUser(
      uid: 'u1',
      email: 'borrower@staki.demo',
      displayName: 'Demo Borrower',
      emailVerified: true,
      provider: provider,
    );

Future<_FakeAuthRepository> _pump(
  WidgetTester tester, {
  String provider = 'password',
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repo = _FakeAuthRepository('OldPass123');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider
            .overrideWith((ref) => Stream.value(_user(provider: provider))),
        changePasswordProvider.overrideWithValue(ChangePassword(repo)),
      ],
      child: const MaterialApp(home: S07ChangePasswordPage()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _fill(
  WidgetTester tester, {
  required String current,
  required String next,
  required String confirm,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), confirm);
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a correct current password changes it', (tester) async {
    final repo = await _pump(tester);
    await _fill(
      tester,
      current: 'OldPass123',
      next: 'NewPass456',
      confirm: 'NewPass456',
    );
    expect(repo.calls, [('OldPass123', 'NewPass456')]);
    expect(repo.currentPassword, 'NewPass456');
  });

  testWidgets('a wrong current password shows a clear message', (tester) async {
    final repo = await _pump(tester);
    await _fill(
      tester,
      current: 'Nope12345',
      next: 'NewPass456',
      confirm: 'NewPass456',
    );
    expect(find.text('Your current password is incorrect.'), findsOneWidget);
    expect(repo.currentPassword, 'OldPass123');

    // The error line appears above the fields; each box keeps its text.
    String textOf(int i) => tester
        .widget<EditableText>(find.byType(EditableText).at(i))
        .controller
        .text;
    expect(textOf(0), 'Nope12345');
    expect(textOf(1), 'NewPass456');
    expect(textOf(2), 'NewPass456');
  });

  testWidgets('a weak or mismatched new password is not sent', (tester) async {
    final repo = await _pump(tester);
    await _fill(tester, current: 'OldPass123', next: 'short', confirm: 'x');
    expect(repo.calls, isEmpty);
    expect(find.textContaining('do not match'), findsOneWidget);
  });

  testWidgets('Google accounts are told there is no password to change',
      (tester) async {
    await _pump(tester, provider: 'google.com');
    expect(find.textContaining('sign in with Google'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
