import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p30_salary_employment_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p31_salary_income_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p40_other_info_page.dart';

Widget _app(Widget page) => ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: page),
    );

bool _ctaEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton)).onPressed != null;

void main() {
  testWidgets('P30 needs an employment type and an employer name',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const P30SalaryEmploymentPage()));
    expect(find.text('Your employment'), findsOneWidget);
    expect(_ctaEnabled(tester), isFalse);

    await tester.tap(find.text('Full-time permanent'));
    await tester.pump();
    expect(_ctaEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextFormField), 'Bank of Kigali');
    await tester.pump();
    expect(_ctaEnabled(tester), isTrue);
  });

  testWidgets('P31 needs both an income range and a tenure', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const P31SalaryIncomePage()));
    expect(find.text('Income & tenure'), findsOneWidget);
    expect(_ctaEnabled(tester), isFalse);

    await tester.tap(find.text('300K–600K RWF'));
    await tester.pump();
    expect(_ctaEnabled(tester), isFalse);

    await tester.tap(find.text('1–3 years'));
    await tester.pump();
    expect(_ctaEnabled(tester), isTrue);
  });

  testWidgets('P40 only requires an occupation; income is optional',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const P40OtherInfoPage()));
    expect(find.text('Optional'), findsOneWidget);
    expect(_ctaEnabled(tester), isFalse);

    await tester.tap(find.text('Freelancer'));
    await tester.pump();
    expect(_ctaEnabled(tester), isTrue);
  });
}
