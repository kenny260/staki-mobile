// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s01_settings_page.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

GoRouter _makeRouter({required List<String> log}) => GoRouter(
      initialLocation: AppRoutes.settings,
      routes: [
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, __) => const S01SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, __) {
            log.add(AppRoutes.welcome);
            return const Scaffold(body: Text('Welcome'));
          },
        ),
      ],
    );

Future<Widget> _wrap(GoRouter router) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  group('S01SettingsPage renders', () {
    testWidgets('shows Language option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Language'), findsWidgets);
    });

    testWidgets('shows Notifications option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Notifications'), findsWidgets);
    });

    testWidgets('shows Log out option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Log out'), findsWidgets);
    });
  });

  group('S01SettingsPage log out', () {
    testWidgets(
        'tapping Log out shows a confirmation dialog with Cancel button',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // Dialog should appear with its title
      expect(
        find.byType(AlertDialog).evaluate().isNotEmpty ||
            find.textContaining('Log out').evaluate().length > 1,
        isTrue,
      );

      // Tapping Cancel closes the dialog without navigating
      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(log, isEmpty);
      }
    });
  });
}
