import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/home/pages/home_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';

const _account = AccountProfile(
  uid: 'u1',
  role: 'borrower',
  displayName: 'Demo Borrower',
  email: 'borrower@staki.demo',
);

class _NoLoan extends MockLifecycleRepository {
  _NoLoan() : super(delay: Duration.zero);

  @override
  Future<LoanAccount> fetchLoan() async =>
      throw const LifecycleException('You do not have a loan yet.');
}

Future<void> _pump(WidgetTester tester, {bool hasLoan = true}) async {
  await tester.binding.setSurfaceSize(const Size(390, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  GoRoute stub(String path, String label) =>
      GoRoute(path: path, builder: (_, __) => Scaffold(body: Text(label)));
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
      stub(AppRoutes.creditPassport, 'PASSPORT'),
      stub(AppRoutes.creditImprove, 'IMPROVE'),
      stub(AppRoutes.myLoans, 'MY LOANS'),
      stub(LoanRoutes.base, 'APPLY'),
      stub(AppRoutes.documents, 'DOCUMENTS'),
      stub(AppRoutes.dataPermissions, 'PERMISSIONS'),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountProfileProvider.overrideWith((ref) async => _account),
        creditPassportRepositoryProvider
            .overrideWithValue(const MockCreditPassportRepository()),
        lifecycleRepositoryProvider.overrideWithValue(
          hasLoan ? MockLifecycleRepository(delay: Duration.zero) : _NoLoan(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapAndExpect(
  WidgetTester tester,
  String tap,
  String screen,
) async {
  await tester.tap(find.text(tap));
  await tester.pumpAndSettle();
  expect(find.text(screen), findsOneWidget);
}

void main() {
  testWidgets('greets the user and shows the score and loan', (tester) async {
    await _pump(tester);

    expect(find.text('Hello, Demo'), findsOneWidget);
    expect(find.text('742'), findsOneWidget);
    expect(find.textContaining('VERY GOOD'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('View my loan'), findsOneWidget);
  });

  testWidgets('with no loan it offers to apply', (tester) async {
    await _pump(tester, hasLoan: false);
    expect(find.text('No loan yet'), findsOneWidget);
    await _tapAndExpect(tester, 'Apply for a loan', 'APPLY');
  });

  testWidgets('View my score opens the Passport tab', (tester) async {
    await _pump(tester);
    await _tapAndExpect(tester, 'View my score', 'PASSPORT');
  });

  testWidgets('View my loan opens the Loans tab', (tester) async {
    await _pump(tester);
    await _tapAndExpect(tester, 'View my loan', 'MY LOANS');
  });

  testWidgets('the shortcuts open documents, permissions and improve',
      (tester) async {
    await _pump(tester);
    await _tapAndExpect(tester, 'My documents', 'DOCUMENTS');

    await _pump(tester);
    await _tapAndExpect(tester, 'Data permissions', 'PERMISSIONS');

    await _pump(tester);
    await _tapAndExpect(tester, 'Improve my score', 'IMPROVE');
  });
}
