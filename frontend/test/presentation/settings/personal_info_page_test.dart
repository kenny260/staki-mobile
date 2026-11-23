import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s05_personal_info_page.dart';

const _account = AccountProfile(
  uid: 'u1',
  role: 'borrower',
  displayName: 'Demo Borrower',
  email: 'borrower@staki.demo',
  phone: '788000111',
);

typedef _Saved = ({String displayName, String phone});

Widget _wrap(List<_Saved> saved) => ProviderScope(
      overrides: [
        accountProfileProvider.overrideWith((ref) async => _account),
        saveAccountDetailsProvider.overrideWithValue(
          ({required displayName, required phone}) async =>
              saved.add((displayName: displayName, phone: phone)),
        ),
      ],
      child: const MaterialApp(home: S05PersonalInfoPage()),
    );

Finder _field(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(Column),
    );

void main() {
  testWidgets('shows the saved name, phone, email and account type',
      (tester) async {
    await tester.pumpWidget(_wrap([]));
    await tester.pumpAndSettle();

    expect(find.text('Demo Borrower'), findsOneWidget);
    expect(find.text('0788000111'), findsOneWidget);
    expect(find.text('borrower@staki.demo'), findsOneWidget);
    expect(find.text('Borrower'), findsOneWidget);
  });

  testWidgets('Save stays disabled until something changes', (tester) async {
    final saved = <_Saved>[];
    await tester.pumpWidget(_wrap(saved));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save changes'));
    await tester.pump();
    expect(saved, isEmpty);
  });

  testWidgets('an invalid phone shows an error and is not saved',
      (tester) async {
    final saved = <_Saved>[];
    await tester.pumpWidget(_wrap(saved));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: _field('Phone number').first,
        matching: find.byType(TextField),
      ),
      '12345',
    );
    await tester.pump();
    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(find.textContaining('valid Rwandan number'), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('a valid change is saved', (tester) async {
    final saved = <_Saved>[];
    await tester.pumpWidget(_wrap(saved));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: _field('Full name').first,
        matching: find.byType(TextField),
      ),
      'Demo B. Uwase',
    );
    await tester.pump();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    expect(saved.single.displayName, 'Demo B. Uwase');
    expect(saved.single.phone, '788000111');
  });
}
