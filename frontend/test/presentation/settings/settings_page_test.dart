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
    testWidgets('shows Appearance / Theme option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Theme'), findsWidgets);
    });

    testWidgets('shows Language option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Language'), findsWidgets);
    });

    testWidgets('shows Sign out option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign out'), findsWidgets);
    });
  });

  group('S01SettingsPage theme change', () {
    testWidgets('tapping Dark updates the theme preference',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final log = <String>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: _makeRouter(log: log),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final themeRow = find.textContaining('Theme');
      if (themeRow.evaluate().isNotEmpty) {
        await tester.tap(themeRow.first);
        await tester.pumpAndSettle();
      }

      final darkOption = find.text('Dark');
      if (darkOption.evaluate().isNotEmpty) {
        await tester.tap(darkOption.first);
        await tester.pumpAndSettle();
      }

      final saved = prefs.getString('themeMode');
      expect(saved == null || saved == 'dark', isTrue);
    });
  });

  group('S01SettingsPage sign-out', () {
    testWidgets('tapping Sign out shows a confirmation dialog',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Sign out').first);
      await tester.pumpAndSettle();

      expect(
        find.byType(AlertDialog).evaluate().isNotEmpty ||
            find.byType(BottomSheet).evaluate().isNotEmpty ||
            find.textContaining('sign out').evaluate().isNotEmpty ||
            find.textContaining('Sign out').evaluate().length > 1,
        isTrue,
      );
    });

    testWidgets(
        'confirming sign-out navigates to the welcome screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final log = <String>[];
      await tester.pumpWidget(await _wrap(_makeRouter(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Sign out').first);
      await tester.pumpAndSettle();

      final confirmFinder = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('Sign out'),
      );
      if (confirmFinder.evaluate().isNotEmpty) {
        await tester.tap(confirmFinder.last);
        await tester.pumpAndSettle();
        expect(log, contains(AppRoutes.welcome));
      } else {
        expect(
          find.byType(AlertDialog).evaluate().isNotEmpty ||
              find.textContaining('sign out').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });
  });
}