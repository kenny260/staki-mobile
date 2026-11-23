import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/presentation/features/profile/pages/profile_page.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';

const _account = AccountProfile(
  uid: 'u1',
  role: 'borrower',
  displayName: 'Demo Borrower',
  email: 'borrower@staki.demo',
);

/// The Profile tab lives inside a StatefulShellRoute, so its page has its
/// own navigator. Closing the Log out dialog must not pop that page.
void main() {
  testWidgets('cancelling Log out on the Profile tab keeps the tab open',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, __) => const Text('Home'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, __) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountProfileProvider.overrideWith((ref) async => _account),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Log out?'), findsNothing);
    expect(find.text('Demo Borrower'), findsOneWidget);
  });
}
