import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';

Future<LoanAccount> _loan(LoanStage stage) =>
    MockLifecycleRepository(stage: stage, delay: Duration.zero).fetchLoan();

void main() {
  test('active loan matches the Figma sample', () async {
    final loan = await _loan(LoanStage.active);
    expect(loan.paidAmount, 277500);
    expect(loan.outstanding, 277500);
    expect(loan.nextPaymentAmount, 92500);
    expect(loan.progress, closeTo(0.5, 0.001));
    expect(loan.payments, hasLength(3));
  });

  test('a fully repaid loan owes nothing', () async {
    final loan = await _loan(LoanStage.fullyRepaid);
    expect(loan.outstanding, 0);
    expect(loan.isRepaid, isTrue);
    expect(loan.nextPaymentAmount, 0);
    expect(loan.progress, 1);
  });

  test('the next payment is capped at what is still owed', () async {
    final loan = (await _loan(LoanStage.active)).copyWith(paidAmount: 500000);
    expect(loan.outstanding, 55000);
    expect(loan.nextPaymentAmount, 55000);
  });

  test('formatMoney and dates match the Figma style', () {
    expect(formatMoney(277500), 'RWF 277,500');
    expect(formatMoney(0), 'RWF 0');
    expect(shortDate(DateTime(2026, 11, 15)), 'Nov 15');
    expect(fullDate(DateTime(2023, 10, 15)), 'Oct 15, 2023');
  });
}
