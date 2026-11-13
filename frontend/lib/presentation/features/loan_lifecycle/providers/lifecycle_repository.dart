import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';

// TEMP: swap the implementation when the Firestore repository exists.
abstract class LifecycleRepository {
  /// READ the user's loan.
  Future<LoanAccount> fetchLoan();

  /// UPDATE: approved becomes disbursement pending.
  Future<LoanAccount> acceptAgreement();

  /// UPDATE: disbursed becomes active.
  Future<LoanAccount> acknowledgeDisbursed();

  /// CREATE a repayment record and UPDATE the loan balance.
  Future<RepaymentReceipt> repay(PayMethod method);
}

class MockLifecycleRepository implements LifecycleRepository {
  MockLifecycleRepository({
    LoanStage stage = LoanStage.active,
    this.delay = const Duration(milliseconds: 500),
    this.failRepay = false,
  }) : _account = _build(stage);

  static const _monthly = 92500;
  static const _total = 555000;

  final Duration delay;

  /// Set to true to preview the payment error.
  final bool failRepay;

  LoanAccount _account;

  static LoanAccount _build(LoanStage stage) {
    final repaid = stage == LoanStage.fullyRepaid;
    final started =
        stage == LoanStage.active || stage == LoanStage.repaymentDue || repaid;
    final count = repaid
        ? 6
        : started
            ? 3
            : 0;
    return LoanAccount(
      partner: 'Bank of Kigali',
      stage: stage,
      approvedAmount: 500000,
      termMonths: 6,
      interestLabel: '1.5% / month',
      monthlyPayment: _monthly,
      totalRepayable: _total,
      paidAmount: count * _monthly,
      payments: List.generate(
        count,
        (i) => Payment(amount: _monthly, date: DateTime(2026, 10 - i, 15)),
      ),
      nextDueDate: started && !repaid ? DateTime(2026, 11, 15) : null,
    );
  }

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<LoanAccount> fetchLoan() async {
    await _wait();
    return _account;
  }

  @override
  Future<LoanAccount> acceptAgreement() async {
    await _wait();
    if (_account.stage != LoanStage.approved) {
      throw const LifecycleException('This loan is not waiting for signing.');
    }
    return _account = _account.copyWith(stage: LoanStage.disbursementPending);
  }

  @override
  Future<LoanAccount> acknowledgeDisbursed() async {
    await _wait();
    if (_account.stage != LoanStage.disbursed) {
      throw const LifecycleException('The funds have not been disbursed yet.');
    }
    return _account = _account.copyWith(
      stage: LoanStage.active,
      nextDueDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  @override
  Future<RepaymentReceipt> repay(PayMethod method) async {
    await _wait();
    if (failRepay) {
      throw const LifecycleException(
        "We couldn't process your payment. Please try again.",
      );
    }
    if (_account.isRepaid) {
      throw const LifecycleException('This loan is already fully repaid.');
    }
    final amount = _account.nextPaymentAmount;
    final now = DateTime.now();
    final paid = _account.paidAmount + amount;
    final repaid = paid >= _account.totalRepayable;
    final due = _account.nextDueDate;
    _account = _account.copyWith(
      stage: repaid ? LoanStage.fullyRepaid : LoanStage.active,
      paidAmount: paid,
      payments: [Payment(amount: amount, date: now), ..._account.payments],
      nextDueDate:
          due == null ? null : DateTime(due.year, due.month + 1, due.day),
      clearDueDate: repaid,
    );
    final suffix = (now.millisecondsSinceEpoch % 100000).toString();
    return RepaymentReceipt(
      reference: 'TXN-${suffix.padLeft(5, '0')}',
      amount: amount,
      partner: _account.partner,
      date: now,
    );
  }
}
