import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/profile/pages/profile_page.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';

const _borrower = AccountProfile(
  uid: 'u1',
  role: 'borrower',
  displayName: 'Demo Borrower',
  email: 'borrower@staki.demo',
  phone: '788000111',
  borrowerType: 'business',
  answers: {'businessName': 'Kigali Fresh Market'},
);

const _lender = AccountProfile(
  uid: 'u2',
  role: 'lender',
  displayName: 'Demo Lender',
  email: 'lender@staki.demo',
);

Future<void> _pump(WidgetTester tester, AccountProfile account) async {
  await tester.binding.setSurfaceSize(const Size(390, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  GoRoute stub(String path, String label) =>
      GoRoute(path: path, builder: (_, __) => Scaffold(body: Text(label)));
  final router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: [
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
      stub(AppRoutes.documents, 'DOCUMENTS SCREEN'),
      stub(AppRoutes.dataPermissions, 'PERMISSIONS SCREEN'),
      stub(AppRoutes.settings, 'SETTINGS SCREEN'),
      stub(AppRoutes.privacy, 'PRIVACY SCREEN'),
      stub(AppRoutes.support, 'SUPPORT SCREEN'),
      stub(AppRoutes.profileRole, 'PROFILE SETUP'),
      stub(MarketRoutes.ledger, 'LEDGER SCREEN'),
      stub(MarketRoutes.notifications, 'NOTIFICATIONS SCREEN'),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [accountProfileProvider.overrideWith((ref) async => account)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _opens(
  WidgetTester tester,
  AccountProfile account,
  String row,
  String screen,
) async {
  await _pump(tester, account);
  await tester.tap(find.text(row));
  await tester.pumpAndSettle();
  expect(find.text(screen), findsOneWidget, reason: row);
}

void main() {
  testWidgets('a borrower sees their details and borrower profile',
      (tester) async {
    await _pump(tester, _borrower);

    expect(find.text('Demo Borrower'), findsOneWidget);
    expect(find.text('DB'), findsOneWidget);
    expect(find.text('borrower@staki.demo'), findsOneWidget);
    expect(find.text('+250 788 000 111'), findsOneWidget);
    expect(find.text('BORROWER'), findsOneWidget);
    expect(find.text('Business owner'), findsOneWidget);
    expect(find.text('Business name'), findsOneWidget);
    expect(find.text('Kigali Fresh Market'), findsOneWidget);
    expect(find.text('Wallet and ledger'), findsNothing);
  });

  testWidgets('borrower rows open the right screens', (tester) async {
    await _opens(tester, _borrower, 'My documents', 'DOCUMENTS SCREEN');
    await _opens(tester, _borrower, 'Data permissions', 'PERMISSIONS SCREEN');
    await _opens(tester, _borrower, 'Settings', 'SETTINGS SCREEN');
    await _opens(tester, _borrower, 'Privacy', 'PRIVACY SCREEN');
    await _opens(tester, _borrower, 'Help and support', 'SUPPORT SCREEN');
  });

  testWidgets('an unfinished borrower profile links to profile setup',
      (tester) async {
    const unfinished = AccountProfile(uid: 'u3', role: 'borrower');
    await _opens(tester, unfinished, 'Profile not completed', 'PROFILE SETUP');
  });

  testWidgets('a lender sees wallet and notifications, not borrower rows',
      (tester) async {
    await _pump(tester, _lender);
    expect(find.text('LENDER'), findsOneWidget);
    expect(find.text('My documents'), findsNothing);
    expect(find.text('Borrower type'), findsNothing);

    await _opens(tester, _lender, 'Wallet and ledger', 'LEDGER SCREEN');
    await _opens(tester, _lender, 'Notifications', 'NOTIFICATIONS SCREEN');
  });

  group('AccountProfile', () {
    test('first name and initials', () {
      expect(_borrower.firstName, 'Demo');
      expect(_borrower.initials, 'DB');
      const emailOnly = AccountProfile(
        uid: 'u4',
        role: 'borrower',
        email: 'amina@staki.demo',
      );
      expect(emailOnly.firstName, 'amina');
      expect(emailOnly.initials, 'A');
      expect(
        const AccountProfile(uid: 'u5', role: 'lender').firstName,
        'there',
      );
    });

    test('borrower type labels', () {
      String label(String? type) =>
          AccountProfile(uid: 'u', role: 'borrower', borrowerType: type)
              .borrowerTypeLabel;
      expect(label('business'), 'Business owner');
      expect(label('startup'), 'Startup founder');
      expect(label('student'), 'Student');
      expect(label('salaried'), 'Salaried employee');
      expect(label('other'), 'Other income');
      expect(label(null), 'Profile not completed');
    });
  });
}
