import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),),
    );

void main() {
  testWidgets('AppCheckboxTile toggles and respects disabled', (tester) async {
    bool? changed;
    await tester.pumpWidget(
      _wrap(
        AppCheckboxTile(
          label: 'I consent',
          value: false,
          onChanged: (v) => changed = v,
        ),
      ),
    );
    await tester.tap(find.text('I consent'));
    expect(changed, isTrue);

    changed = null;
    await tester.pumpWidget(
      _wrap(
        const AppCheckboxTile(
          label: 'Not available',
          value: false,
          onChanged: null,
        ),
      ),
    );
    await tester.tap(find.text('Not available'));
    expect(changed, isNull);
  });

  testWidgets('AppSwitchTile reports the new value', (tester) async {
    bool? changed;
    await tester.pumpWidget(
      _wrap(
        AppSwitchTile(
          title: 'Email notifications',
          subtitle: 'Loan approvals, score updates',
          value: false,
          onChanged: (v) => changed = v,
        ),
      ),
    );
    await tester.tap(find.byType(AppSwitch));
    expect(changed, isTrue);
  });

  testWidgets('AppTabs and SegmentControl report the tapped index',
      (tester) async {
    int? tab;
    int? segment;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            AppTabs(
              labels: const ['Score', 'Details', 'Data'],
              selectedIndex: 0,
              onChanged: (i) => tab = i,
            ),
            const SizedBox(height: 16),
            SegmentControl(
              labels: const ['Borrower', 'Lender'],
              selectedIndex: 0,
              onChanged: (i) => segment = i,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Details'));
    await tester.tap(find.text('Lender'));
    expect(tab, 1);
    expect(segment, 1);
  });

  testWidgets('AppBottomNav reports the tapped item', (tester) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            items: const [
              BottomNavItem(label: 'Home', icon: Icons.home_outlined),
              BottomNavItem(label: 'Passport', icon: Icons.badge_outlined),
              BottomNavItem(
                  label: 'Loans', icon: Icons.account_balance_outlined,),
              BottomNavItem(label: 'Profile', icon: Icons.person_outline),
            ],
            selectedIndex: 0,
            onChanged: (i) => picked = i,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Loans'));
    expect(picked, 2);
  });

  testWidgets('StepIndicator shows "n of N"', (tester) async {
    await tester.pumpWidget(_wrap(const StepIndicator(step: 2, totalSteps: 4)));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
  });

  testWidgets('KeyValueRow and ScreenHeader render their text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ScreenHeader(
                title: 'Your Credit Passport', subtitle: 'Score · 742',),
            KeyValueRow(label: 'Amount', value: '500,000 RWF'),
          ],
        ),
      ),
    );
    expect(find.text('Your Credit Passport'), findsOneWidget);
    expect(find.text('500,000 RWF'), findsOneWidget);
  });

  testWidgets('long label with an Optional tag does not overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            OptionChips(
              label: 'Approximate monthly income / support (RWF)',
              isOptional: true,
              options: [],
              selected: null,
              onSelected: _ignore,
            ),
            AppTextField(
              label: 'Estimated monthly income or support in RWF',
              isOptional: true,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

void _ignore(String _) {}
