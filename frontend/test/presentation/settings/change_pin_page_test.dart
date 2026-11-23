import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/data/datasources/pin_store.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s06_change_pin_page.dart';

const _user = AppUser(
  uid: 'u1',
  email: 'borrower@staki.demo',
  displayName: 'Demo Borrower',
  emailVerified: true,
  provider: 'password',
);

Future<PinStore> _pump(WidgetTester tester, {String? savedPin}) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  FlutterSecureStorage.setMockInitialValues({});
  final store = PinStore();
  if (savedPin != null) await store.save('u1', savedPin);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(_user)),
        pinStoreProvider.overrideWithValue(store),
      ],
      child: const MaterialApp(home: S06ChangePinPage()),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

Future<void> _type(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.bySemanticsLabel(d));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('with a saved PIN: current, new, confirm changes it',
      (tester) async {
    final store = await _pump(tester, savedPin: '1234');
    expect(find.text('Enter your current PIN'), findsOneWidget);

    await _type(tester, '1234');
    expect(find.text('Enter a new PIN'), findsOneWidget);

    await _type(tester, '5678');
    expect(find.text('Confirm your new PIN'), findsOneWidget);

    await _type(tester, '5678');
    expect(await store.verify('u1', '5678'), isTrue);
    expect(await store.verify('u1', '1234'), isFalse);
  });

  testWidgets('a wrong current PIN is refused and shows tries left',
      (tester) async {
    final store = await _pump(tester, savedPin: '1234');
    await _type(tester, '0000');

    expect(find.text('Enter your current PIN'), findsOneWidget);
    expect(find.textContaining('4 tries left'), findsOneWidget);
    expect(await store.verify('u1', '1234'), isTrue);
  });

  testWidgets('five wrong PINs lock the screen', (tester) async {
    await _pump(tester, savedPin: '1234');
    for (var i = 0; i < S06ChangePinPage.maxAttempts; i++) {
      await _type(tester, '0000');
    }
    expect(find.text('PIN locked'), findsOneWidget);
    expect(find.bySemanticsLabel('1'), findsNothing);
  });

  testWidgets('the new PIN cannot be the current one', (tester) async {
    await _pump(tester, savedPin: '1234');
    await _type(tester, '1234');
    await _type(tester, '1234');
    expect(find.textContaining('different from your current'), findsOneWidget);
    expect(find.text('Enter a new PIN'), findsOneWidget);
  });

  testWidgets('a confirm that does not match starts the new PIN again',
      (tester) async {
    final store = await _pump(tester, savedPin: '1234');
    await _type(tester, '1234');
    await _type(tester, '5678');
    await _type(tester, '5679');

    expect(find.textContaining('do not match'), findsOneWidget);
    expect(find.text('Enter a new PIN'), findsOneWidget);
    expect(await store.verify('u1', '1234'), isTrue);
  });

  testWidgets('with no saved PIN it goes straight to setting one',
      (tester) async {
    final store = await _pump(tester);
    expect(find.text('Set your PIN'), findsOneWidget);

    await _type(tester, '2468');
    await _type(tester, '2468');
    expect(await store.verify('u1', '2468'), isTrue);
  });
}
