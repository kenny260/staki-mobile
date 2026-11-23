// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a03_role_select_page.dart';

GoRouter _makeRouter({required List<String> log}) => GoRouter(
      initialLocation: AppRoutes.roleSelect,
      routes: [
        GoRoute(
          path: AppRoutes.roleSelect,
          builder: (_, __) => const A03RoleSelectPage(),
        ),
        GoRoute(
          path: AppRoutes.borrowerConfirmed,
          builder: (_, __) {
            log.add(AppRoutes.borrowerConfirmed);
            return const Scaffold(body: Text('BorrowerConfirmed'));
          },
        ),
        GoRoute(
          path: AppRoutes.lenderConfirmed,
          builder: (_, __) {
            log.add(AppRoutes.lenderConfirmed);
            return const Scaffold(body: Text('LenderConfirmed'));
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
  group('A03RoleSelectPage CTA gating', () {
    testWidgets('Continue is disabled before a role is picked', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(tester.binding.setSurfaceSize);

      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      // The CTA button text at start has no role-specific label
      // — it is simply disabled; verify no navigation fires when tapped
      await tester.tap(
        find.byType(ElevatedButton).last,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(log, isEmpty);
    });

    testWidgets('selecting Borrower changes CTA to Continue as Borrower',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(tester.binding.setSurfaceSize);

      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Borrower'));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Borrower'), findsOneWidget);
    });

    testWidgets('selecting Lender changes CTA to Continue as Lender',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(tester.binding.setSurfaceSize);

      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lender'));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Lender'), findsOneWidget);
    });

    testWidgets('tapping Continue as Borrower navigates to borrower confirmed',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(tester.binding.setSurfaceSize);

      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Borrower'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Borrower'));
      await tester.pumpAndSettle();

      expect(log, contains(AppRoutes.borrowerConfirmed));
    });

    testWidgets('tapping Continue as Lender navigates to lender confirmed',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(tester.binding.setSurfaceSize);

      final log = <String>[];
      await tester.pumpWidget(_wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lender'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Lender'));
      await tester.pumpAndSettle();

      expect(log, contains(AppRoutes.lenderConfirmed));
    });
  });
}
