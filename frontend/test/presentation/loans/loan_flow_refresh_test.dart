import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

/// Counts how often Home and the Loans tab load the loan.
class _CountingLoans extends MockLifecycleRepository {
  _CountingLoans() : super(delay: Duration.zero);

  int loads = 0;

  @override
  Future<LoanAccount> fetchLoan() {
    loads++;
    return super.fetchLoan();
  }
}

ProviderContainer _container(_CountingLoans loans) {
  final container = ProviderContainer(
    overrides: [
      lifecycleRepositoryProvider.overrideWithValue(loans),
      loanRepositoryProvider
          .overrideWithValue(MockLoanRepository(delay: Duration.zero)),
    ],
  );
  addTearDown(container.dispose);
  // Keep the loan provider listened to, like Home and the Loans tab do.
  container.listen(loanAccountProvider, (_, __) {});
  return container;
}

void main() {
  test('submitting an application reloads the loan shown on Home and Loans',
      () async {
    final loans = _CountingLoans();
    final container = _container(loans);
    await container.read(loanAccountProvider.future);
    expect(loans.loads, 1);

    final flow = container.read(loanFlowProvider.notifier)
      ..setPurpose(LoanPurpose.inventory);
    expect(await flow.submit(), isNotNull);
    await container.read(loanAccountProvider.future);

    expect(loans.loads, 2);
  });

  test('cancelling an application reloads the loan too', () async {
    final loans = _CountingLoans();
    final container = _container(loans);
    await container.read(loanAccountProvider.future);

    expect(
      await container.read(loanFlowProvider.notifier).cancelApplication(),
      isTrue,
    );
    await container.read(loanAccountProvider.future);

    expect(loans.loads, 2);
  });
}
