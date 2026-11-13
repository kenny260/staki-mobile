import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loans/pages/funding_options_page.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

Future<void> _show(WidgetTester tester, EligibilityStatus status) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(
          MockLoanRepository(status: status, delay: Duration.zero),
        ),
      ],
      child: const MaterialApp(home: FundingOptionsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the offer when eligible', (tester) async {
    await _show(tester, EligibilityStatus.eligible);
    expect(find.text('Funding available to you'), findsOneWidget);
    expect(find.text('Up to RWF 1,200,000'), findsOneWidget);
    expect(find.text('PRE-QUALIFIED'), findsOneWidget);
    expect(find.text('View offer'), findsOneWidget);
  });

  testWidgets('shows pending verification when partially eligible', (
    tester,
  ) async {
    await _show(tester, EligibilityStatus.partiallyEligible);
    expect(find.text('Up to RWF 500,000'), findsOneWidget);
    expect(find.text('PENDING VERIFICATION'), findsOneWidget);
  });

  testWidgets('shows tips when not eligible', (tester) async {
    await _show(tester, EligibilityStatus.notEligible);
    expect(find.text('No matching offers right now'), findsOneWidget);
    expect(find.text('Keep your connections active'), findsOneWidget);
  });
}
