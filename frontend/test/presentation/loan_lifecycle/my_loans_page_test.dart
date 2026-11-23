import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/lifecycle_routes.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/my_loans_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

/// The borrower's loan, which disappears once the application is withdrawn.
class _Loans extends MockLifecycleRepository {
  _Loans(LoanStage? stage)
      : _hasLoan = stage != null,
        super(stage: stage ?? LoanStage.active, delay: Duration.zero);

  bool _hasLoan;

  @override
  Future<LoanAccount> fetchLoan() async {
    if (!_hasLoan) throw const LifecycleException('You do not have a loan.');
    return super.fetchLoan();
  }
}

class _Applications extends MockLoanRepository {
  _Applications(this.loans, {this.fail = false}) : super(delay: Duration.zero);

  final _Loans loans;
  final bool fail;
  int cancelCalls = 0;

  @override
  Future<void> cancelApplication() async {
    cancelCalls++;
    if (fail) throw const LoanException('Already in review.');
    loans._hasLoan = false;
  }
}

Future<_Applications> _pump(
  WidgetTester tester, {
  LoanStage? stage,
  bool failCancel = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final loans = _Loans(stage);
  final applications = _Applications(loans, fail: failCancel);
  final router = GoRouter(
    initialLocation: '/my-loans',
    routes: [
      GoRoute(path: '/my-loans', builder: (_, __) => const MyLoansPage()),
      GoRoute(
        path: LifecycleRoutes.base,
        builder: (_, __) => const Scaffold(body: Text('LOAN DETAILS')),
      ),
      GoRoute(
        path: LifecycleRoutes.repay,
        builder: (_, __) => const Scaffold(body: Text('REPAY')),
      ),
      GoRoute(
        path: LoanRoutes.base,
        builder: (_, __) => const Scaffold(body: Text('APPLY')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lifecycleRepositoryProvider.overrideWithValue(loans),
        loanRepositoryProvider.overrideWithValue(applications),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return applications;
}

void main() {
  testWidgets('no loan: offers Apply for a loan', (tester) async {
    await _pump(tester);
    expect(find.text('No loan yet'), findsOneWidget);

    await tester.tap(find.text('Apply for a loan'));
    await tester.pumpAndSettle();
    expect(find.text('APPLY'), findsOneWidget);
  });

  testWidgets('an active loan: details and repayment, no cancel',
      (tester) async {
    await _pump(tester, stage: LoanStage.active);
    expect(find.textContaining('Active'), findsOneWidget);
    expect(find.text('Make a repayment'), findsOneWidget);
    expect(find.text('Cancel application'), findsNothing);

    await tester.tap(find.text('Make a repayment'));
    await tester.pumpAndSettle();
    expect(find.text('REPAY'), findsOneWidget);
  });

  testWidgets('a submitted application can be cancelled', (tester) async {
    final applications = await _pump(tester, stage: LoanStage.submitted);
    expect(find.textContaining('Application submitted'), findsOneWidget);
    expect(find.text('Make a repayment'), findsNothing);

    await tester.tap(find.text('Cancel application'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel application?'), findsOneWidget);

    await tester.tap(find.text('Cancel application').last);
    await tester.pumpAndSettle();

    expect(applications.cancelCalls, 1);
    expect(find.text('Application cancelled.'), findsOneWidget);
    // The tab refreshes and now offers a new application.
    expect(find.text('Apply for a loan'), findsOneWidget);
  });

  testWidgets('Keep it leaves the application alone', (tester) async {
    final applications = await _pump(tester, stage: LoanStage.submitted);

    await tester.tap(find.text('Cancel application'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();

    expect(applications.cancelCalls, 0);
    expect(find.text('Cancel application'), findsOneWidget);
  });

  testWidgets('if the loan is already in review the cancel is refused',
      (tester) async {
    final applications =
        await _pump(tester, stage: LoanStage.submitted, failCancel: true);

    await tester.tap(find.text('Cancel application'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel application').last);
    await tester.pumpAndSettle();

    expect(applications.cancelCalls, 1);
    expect(
      find.text("We couldn't cancel it. Please try again."),
      findsOneWidget,
    );
    expect(find.text('Cancel application'), findsOneWidget);
  });

  testWidgets('View loan details opens the loan', (tester) async {
    await _pump(tester, stage: LoanStage.submitted);
    await tester.tap(find.text('View loan details'));
    await tester.pumpAndSettle();
    expect(find.text('LOAN DETAILS'), findsOneWidget);
  });
}
