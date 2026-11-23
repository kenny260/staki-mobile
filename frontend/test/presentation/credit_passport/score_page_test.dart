import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';

/// No scores/{uid} document yet.
class _NoScoreRepository extends MockCreditPassportRepository {
  const _NoScoreRepository();

  @override
  Stream<CreditScore?> watchScore() => Stream.value(null);
}

Future<void> _pump(
  WidgetTester tester, {
  CreditPassportRepository repo = const MockCreditPassportRepository(),
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = GoRouter(
    initialLocation: AppRoutes.creditPassport,
    routes: [
      GoRoute(
        path: AppRoutes.creditPassport,
        builder: (_, __) => const ScorePage(),
      ),
      GoRoute(
        path: AppRoutes.creditAssessment,
        builder: (_, __) => const Scaffold(body: Text('ASSESSMENT')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [creditPassportRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ScorePage shows the score and factor cards', (tester) async {
    await _pump(tester);

    expect(find.text('742'), findsOneWidget);
    expect(find.text('VERY GOOD'), findsOneWidget);
    expect(find.text('Cash-flow strength'), findsOneWidget);
  });

  testWidgets('Refresh my score runs a new assessment', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Refresh my score'));
    await tester.pumpAndSettle();
    expect(find.text('ASSESSMENT'), findsOneWidget);
  });

  testWidgets('with no score yet it offers Run my assessment', (tester) async {
    await _pump(tester, repo: const _NoScoreRepository());

    expect(find.text('No Credit Passport yet'), findsOneWidget);
    expect(find.text('Refresh my score'), findsNothing);

    await tester.tap(find.text('Run my assessment'));
    await tester.pumpAndSettle();
    expect(find.text('ASSESSMENT'), findsOneWidget);
  });
}
