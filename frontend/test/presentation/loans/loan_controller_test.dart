import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      loanRepositoryProvider.overrideWithValue(
        MockLoanRepository(delay: Duration.zero),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('start gives a default draft capped at the maximum amount', () async {
    final container = _container();
    await container.read(loanFlowProvider.notifier).start(maxAmount: 300000);
    expect(container.read(loanFlowProvider).amount, 300000);
    expect(container.read(loanFlowProvider).termMonths, 6);
  });

  test('a saved draft is read back', () async {
    final container = _container();
    final controller = container.read(loanFlowProvider.notifier)
      ..setAmount(200000)
      ..setTerm(9);
    expect(await controller.saveDraft(), isTrue);

    controller.setAmount(100000);
    await controller.start(maxAmount: 1200000);
    expect(container.read(loanFlowProvider).amount, 200000);
    expect(container.read(loanFlowProvider).termMonths, 9);
  });

  test('discarding removes the saved draft', () async {
    final container = _container();
    final controller = container.read(loanFlowProvider.notifier)
      ..setAmount(200000);
    await controller.saveDraft();
    expect(await controller.discardDraft(), isTrue);
    expect(await container.read(loanRepositoryProvider).loadDraft(), isNull);
  });

  test('submit without a purpose fails', () async {
    final container = _container();
    final application =
        await container.read(loanFlowProvider.notifier).submit();
    expect(application, isNull);
  });

  test('submit creates an application and moves to under review', () async {
    final container = _container();
    final controller = container.read(loanFlowProvider.notifier)
      ..setPurpose(LoanPurpose.inventory);
    final application = await controller.submit();
    expect(application, isNotNull);
    expect(application!.amount, 500000);

    final result = await container.read(eligibilityProvider.future);
    expect(result.status, EligibilityStatus.underReview);
  });

  test('cancelling the application brings the offer back', () async {
    final container = _container();
    final controller = container.read(loanFlowProvider.notifier)
      ..setPurpose(LoanPurpose.equipment);
    await controller.submit();
    expect(await controller.cancelApplication(), isTrue);

    final result = await container.read(eligibilityProvider.future);
    expect(result.status, EligibilityStatus.eligible);
  });
}
