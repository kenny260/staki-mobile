import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/router/main_shell.dart';

/// A tab screen that reports whether it counts as a tab root.
class _Screen extends StatelessWidget {
  const _Screen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Text('$label root=${isTabRoot(context)}'),
      );
}

GoRouter _router() {
  StatefulShellBranch branch(String path, String label) => StatefulShellBranch(
        routes: [GoRoute(path: path, builder: (_, __) => _Screen(label))],
      );
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShell(navigationShell: shell, items: borrowerTabs),
        branches: [
          branch(AppRoutes.home, 'HOME'),
          branch(AppRoutes.creditPassport, 'PASSPORT'),
          branch(AppRoutes.myLoans, 'LOANS'),
          branch(AppRoutes.profile, 'PROFILE'),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const _Screen('SETTINGS'),
      ),
    ],
  );
}

void main() {
  testWidgets('the bar has four tabs and switches between them',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Passport', 'Loans', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('HOME root=true'), findsOneWidget);

    await tester.tap(find.text('Loans'));
    await tester.pumpAndSettle();
    expect(find.text('LOANS root=true'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE root=true'), findsOneWidget);

    // Tapping the current tab again stays on its first screen.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE root=true'), findsOneWidget);
  });

  testWidgets('Android back on another tab returns to Home', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _router()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Passport'));
    await tester.pumpAndSettle();
    expect(find.text('PASSPORT root=true'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.text('HOME root=true'), findsOneWidget);
  });

  testWidgets('screens outside the tabs are not tab roots', (tester) async {
    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS root=false'), findsOneWidget);
  });

  testWidgets('without a router nothing is a tab root', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _Screen('ALONE')));
    expect(find.text('ALONE root=false'), findsOneWidget);
  });
}
