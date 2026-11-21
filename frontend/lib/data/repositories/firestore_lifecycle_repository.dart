import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/data/datasources/loan_datasource.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';

/// The borrower's current loan and its repayments on Firestore.
///
/// Stage changes (signing, disbursement, confirming a payment) are made by
/// the lending partner on the server; the rules do not let the app change
/// a loan. A repayment is saved as 'pending' in `repayments`, and the screen
/// shows it straight away while the server confirms it.
class FirestoreLifecycleRepository implements LifecycleRepository {
  FirestoreLifecycleRepository({
    required LoanDatasource datasource,
    required String uid,
  })  : _datasource = datasource,
        _uid = uid;

  final LoanDatasource _datasource;
  final String _uid;

  String? _loanId;
  LoanAccount? _account;

  static LoanStage stageFrom(Object? value) => LoanStage.values.firstWhere(
        (s) => s.name == value,
        orElse: () => LoanStage.submitted,
      );

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  @override
  Future<LoanAccount> fetchLoan() async {
    final loans = await _datasource.loansOf(_uid);
    if (loans.isEmpty) {
      throw const LifecycleException('You do not have a loan yet.');
    }
    final loan = loans.first;
    final loanId = loan['id'] as String;
    final repayments = await _datasource.repaymentsOf(_uid, loanId);
    final payments = repayments
        .where((r) => r['status'] != 'failed')
        .map(
          (r) => Payment(
            amount: _int(r['amount']),
            date: (r['paidAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _loanId = loanId;
    return _account = LoanAccount(
      partner: loan['partner'] as String? ?? 'Bank of Kigali',
      stage: stageFrom(loan['stage']),
      approvedAmount: _int(loan['approvedAmount'] ?? loan['amount']),
      termMonths: _int(loan['termMonths']),
      interestLabel: loan['interestLabel'] as String? ?? '',
      monthlyPayment: _int(loan['monthlyPayment']),
      totalRepayable: _int(loan['totalRepayable']),
      paidAmount: _int(loan['paidAmount']),
      payments: payments,
      nextDueDate: (loan['nextDueDate'] as Timestamp?)?.toDate(),
    );
  }

  Future<LoanAccount> _current() async => _account ?? await fetchLoan();

  @override
  Future<LoanAccount> acceptAgreement() async {
    final account = await _current();
    if (account.stage != LoanStage.approved) {
      throw const LifecycleException('This loan is not waiting for signing.');
    }
    return _account = account.copyWith(stage: LoanStage.disbursementPending);
  }

  @override
  Future<LoanAccount> acknowledgeDisbursed() async {
    final account = await _current();
    if (account.stage != LoanStage.disbursed) {
      throw const LifecycleException('The funds have not been disbursed yet.');
    }
    return _account = account.copyWith(stage: LoanStage.active);
  }

  @override
  Future<RepaymentReceipt> repay(PayMethod method) async {
    final account = await _current();
    final loanId = _loanId;
    if (loanId == null) {
      throw const LifecycleException('You do not have a loan yet.');
    }
    if (account.isRepaid) {
      throw const LifecycleException('This loan is already fully repaid.');
    }
    final amount = account.nextPaymentAmount;
    final now = DateTime.now();
    final suffix = (now.millisecondsSinceEpoch % 100000).toString();
    final reference = 'TXN-${suffix.padLeft(5, '0')}';
    try {
      await _datasource.createRepayment({
        'loanId': loanId,
        'borrowerId': _uid,
        'amount': amount,
        'method': method.name,
        'reference': reference,
        'status': 'pending',
      });
    } on FirebaseException {
      throw const LifecycleException(
        "We couldn't process your payment. Please try again.",
      );
    }
    final paid = account.paidAmount + amount;
    final repaid = paid >= account.totalRepayable;
    final due = account.nextDueDate;
    _account = account.copyWith(
      stage: repaid ? LoanStage.fullyRepaid : account.stage,
      paidAmount: paid,
      payments: [Payment(amount: amount, date: now), ...account.payments],
      nextDueDate:
          due == null ? null : DateTime(due.year, due.month + 1, due.day),
      clearDueDate: repaid,
    );
    return RepaymentReceipt(
      reference: reference,
      amount: amount,
      partner: account.partner,
      date: now,
    );
  }
}
