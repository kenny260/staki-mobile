import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';

Future<ProviderContainer> _container(
  LoanStage stage, {
  bool failRepay = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      lifecycleRepositoryProvider.overrideWithValue(
        MockLifecycleRepository(
          stage: stage,
          delay: Duration.zero,
          failRepay: failRepay,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(loanAccountProvider.future);
  return container;
}

LoanAccount _loan(ProviderContainer container) =>
    container.read(loanAccountProvider).requireValue;

void main() {
  test('signing an approved loan moves it to disbursement pending', () async {
    final container = await _container(LoanStage.approved);
    final ok =
        await container.read(loanAccountProvider.notifier).acceptAgreement();
    expect(ok, isTrue);
    expect(_loan(container).stage, LoanStage.disbursementPending);
  });

  test('signing is refused when the loan is not approved', () async {
    final container = await _container(LoanStage.active);
    final ok =
        await container.read(loanAccountProvider.notifier).acceptAgreement();
    expect(ok, isFalse);
  });

  test('a disbursed loan becomes active when opened', () async {
    final container = await _container(LoanStage.disbursed);
    final ok = await container
        .read(loanAccountProvider.notifier)
        .acknowledgeDisbursed();
    expect(ok, isTrue);
    expect(_loan(container).stage, LoanStage.active);
  });

  test('a repayment creates a receipt and lowers the balance', () async {
    final container = await _container(LoanStage.repaymentDue);
    final receipt = await container
        .read(loanAccountProvider.notifier)
        .repay(PayMethod.momo);

    expect(receipt, isNotNull);
    expect(receipt!.amount, 92500);
    expect(container.read(lastReceiptProvider), isNotNull);
    expect(_loan(container).outstanding, 185000);
    expect(_loan(container).stage, LoanStage.active);
    expect(_loan(container).payments, hasLength(4));
  });

  test('paying every instalment fully repays the loan', () async {
    final container = await _container(LoanStage.active);
    final controller = container.read(loanAccountProvider.notifier);
    for (var i = 0; i < 3; i++) {
      expect(await controller.repay(PayMethod.bank), isNotNull);
    }
    expect(_loan(container).stage, LoanStage.fullyRepaid);
    expect(_loan(container).outstanding, 0);
    expect(await controller.repay(PayMethod.bank), isNull);
  });

  test('a failed payment changes nothing', () async {
    final container = await _container(LoanStage.active, failRepay: true);
    final receipt = await container
        .read(loanAccountProvider.notifier)
        .repay(PayMethod.momo);
    expect(receipt, isNull);
    expect(_loan(container).outstanding, 277500);
  });
}
