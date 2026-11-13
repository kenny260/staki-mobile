import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_profile_type_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_welcome_page.dart';

void main() {
  testWidgets('welcome page shows the pitch and the button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LenderWelcomePage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Fund opportunities with better information'),
      findsOneWidget,
    );
    expect(find.text('Create Investor Account'), findsOneWidget);
  });

  testWidgets('Continue stays disabled until a profile type is chosen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LenderProfileTypePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Investor Profile'), findsOneWidget);
    expect(find.text('Individual investor'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Individual investor'));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
