import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/loan_details_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';

Future<void> _show(WidgetTester tester, LoanStage stage) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lifecycleRepositoryProvider.overrideWithValue(
          MockLifecycleRepository(stage: stage, delay: Duration.zero),
        ),
      ],
      child: const MaterialApp(home: LoanDetailsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('active loan shows balance, next payment and history', (
    tester,
  ) async {
    await _show(tester, LoanStage.active);
    expect(find.text('RWF 277,500'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Make repayment'), findsOneWidget);
    expect(find.text('Payment History'), findsOneWidget);
  });

  testWidgets('an approved loan asks the user to sign', (tester) async {
    await _show(tester, LoanStage.approved);
    expect(find.text('Your funding is approved'), findsOneWidget);
    expect(find.text('Accept & Sign Agreement'), findsOneWidget);
  });

  testWidgets('a declined loan offers other options', (tester) async {
    await _show(tester, LoanStage.declined);
    expect(find.text('Application declined'), findsOneWidget);
    expect(find.text('Explore other options'), findsOneWidget);
  });

  testWidgets('a repaid loan shows the thank-you box', (tester) async {
    await _show(tester, LoanStage.fullyRepaid);
    expect(find.text('Loan fully repaid'), findsOneWidget);
    expect(find.text('FULLY REPAID'), findsOneWidget);
    expect(find.text('Make repayment'), findsNothing);
  });
}
