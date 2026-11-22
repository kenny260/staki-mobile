import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/features/onboarding/widgets/pin_entry_view.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

Future<void> _type(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    // The Set/Confirm stepper also shows "1" and "2", so tap inside the pad.
    final key = find.descendant(
      of: find.byType(PinPad),
      matching: find.text(d),
    );
    await tester.tap(key);
    await tester.pump();
  }
}

void main() {
  testWidgets('reports the PIN once four digits are entered', (tester) async {
    String? done;
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        PinEntryView(
          heading: 'Create a secure PIN',
          subtitle: '4-digit PIN for quick access',
          activeStep: 1,
          onCompleted: (p) => done = p,
        ),
      ),
    );

    await _type(tester, '123');
    await tester.pump(const Duration(milliseconds: 300));
    expect(done, isNull);

    await _type(tester, '4');
    await tester.pump(const Duration(milliseconds: 300));
    expect(done, '1234');
  });

  testWidgets('backspace removes the last digit', (tester) async {
    String? done;
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        PinEntryView(
          heading: 'Create a secure PIN',
          subtitle: 's',
          activeStep: 1,
          onCompleted: (p) => done = p,
        ),
      ),
    );

    await _type(tester, '12');
    await tester.tap(find.byIcon(AppIcons.backspace));
    await tester.pump();
    await _type(tester, '345');
    await tester.pump(const Duration(milliseconds: 300));
    expect(done, '1345');
  });

  testWidgets('Show PIN toggles the label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        PinEntryView(
          heading: 'h',
          subtitle: 's',
          activeStep: 1,
          onCompleted: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('Show PIN'));
    await tester.pump();
    expect(find.text('Hide PIN'), findsOneWidget);
  });
}
