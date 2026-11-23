// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a02_welcome_page.dart';

GoRouter _makeRouter({required List<String> log}) => GoRouter(
      initialLocation: AppRoutes.welcome,
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, __) => const A02WelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.roleSelect,
          builder: (_, __) {
            log.add(AppRoutes.roleSelect);
            return const Scaffold(body: Text('RoleSelect'));
          },
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) {
            log.add(AppRoutes.login);
            return const Scaffold(body: Text('Login'));
          },
        ),
      ],
    );

Widget _wrap(GoRouter router) => ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );

void main() {
  group('A02WelcomePage content', () {
    testWidgets('shows the main heading', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(
        find.text('Turn your financial activity into opportunity.'),
        findsOneWidget,
      );
    });

    testWidgets('shows all three trust chips', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.text('BNR regulated'), findsOneWidget);
      expect(find.text('Read-only data'), findsOneWidget);
      expect(find.text('Revocable anytime'), findsOneWidget);
    });

    testWidgets('shows Get started button', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('shows I already have an account link', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.text('I already have an account'), findsOneWidget);
    });
  });

  group('A02WelcomePage navigation', () {
    testWidgets('Get started navigates to role select', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(log, contains(AppRoutes.roleSelect));
    });

    testWidgets(
        'I already have an account navigates to login', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();

      expect(log, contains(AppRoutes.login));
    });
  });
}
