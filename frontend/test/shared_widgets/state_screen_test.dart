import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

void main() {
  test('there are exactly 34 edge cases, E01 to E34, in order', () {
    expect(EdgeCaseType.values.length, 34);
    for (var i = 0; i < EdgeCaseType.values.length; i++) {
      final code = 'E${(i + 1).toString().padLeft(2, '0')}';
      expect(EdgeCaseType.values[i].content.code, code);
    }
  });

  testWidgets('every message state shows its title without overflowing',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568)); // small phone
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final type in EdgeCaseType.values) {
      if (type == EdgeCaseType.loading || type == EdgeCaseType.skeleton) {
        continue;
      }
      await tester.pumpWidget(_app(StateScreen(type: type)));
      expect(find.text(type.content.title), findsOneWidget, reason: type.name);
      expect(tester.takeException(), isNull, reason: type.name);
    }
  });

  testWidgets('primary and secondary buttons call their callbacks',
      (tester) async {
    var primary = 0;
    var secondary = 0;
    await tester.pumpWidget(
      _app(
        StateScreen(
          type: EdgeCaseType.offline,
          onPrimary: () => primary++,
          onSecondary: () => secondary++,
        ),
      ),
    );
    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Check network settings'));
    expect(primary, 1);
    expect(secondary, 1);
  });

  testWidgets('loading and skeleton states render', (tester) async {
    await tester
        .pumpWidget(_app(const StateScreen(type: EdgeCaseType.loading)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Processing securely'), findsOneWidget);

    await tester
        .pumpWidget(_app(const StateScreen(type: EdgeCaseType.skeleton)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
