import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

void main() {
  testWidgets('OtpInput reports completion with all six digits',
      (tester) async {
    String? completed;
    await tester.pumpWidget(_wrap(OtpInput(onCompleted: (v) => completed = v)));
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(completed, '123456');
  });

  testWidgets('AppButton is disabled when onPressed is null', (tester) async {
    await tester
        .pumpWidget(_wrap(const AppButton(label: 'Continue', onPressed: null)));
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('RadioCard calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        RadioCard(
          icon: Icons.person,
          title: 'Student',
          subtitle: 'University',
          selected: false,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Student'));
    expect(taps, 1);
  });

  testWidgets('OptionChips reports the tapped option', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        OptionChips(
          label: 'Years operating',
          options: const ['1-2 years', '2-5 years'],
          selected: null,
          onSelected: (v) => picked = v,
        ),
      ),
    );
    await tester.tap(find.text('2-5 years'));
    expect(picked, '2-5 years');
  });
}
