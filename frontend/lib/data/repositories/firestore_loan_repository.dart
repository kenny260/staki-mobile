import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/data/datasources/loan_datasource.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

/// Loan applications on Firestore (collection `loans`).
///
/// Eligibility comes from the borrower's Credit Passport in `scores/{uid}`.
/// The draft is kept on the device until the borrower submits it, because
/// the rules only accept complete applications.
class FirestoreLoanRepository implements LoanRepository {
  FirestoreLoanRepository({
    required LoanDatasource datasource,
    required String uid,
  })  : _datasource = datasource,
        _uid = uid;

  final LoanDatasource _datasource;
  final String _uid;
  LoanDraft? _draft;

  static const partner = 'Bank of Kigali';
  static const interestLabel = '1.5% monthly';
  static const offerTermMonths = 6;

  /// The largest loan offered for a score. Below 580 (Poor) nothing is
  /// offered; Fair is offered a smaller amount pending verification.
  static int maxAmountFor(int score) {
    if (score >= 740) return 1200000;
    if (score >= 670) return 800000;
    if (score >= 580) return 500000;
    return 0;
  }

  Future<Map<String, dynamic>?> _pendingApplication() async {
    final loans = await _datasource.loansOf(_uid);
    for (final loan in loans) {
      if (loan['stage'] == 'submitted' || loan['stage'] == 'underReview') {
        return loan;
      }
    }
    return null;
  }

  @override
  Future<EligibilityResult> fetchEligibility() async {
    if (await _pendingApplication() != null) {
      return const EligibilityResult(status: EligibilityStatus.underReview);
    }
    final score = await _datasource.scoreOf(_uid);
    final value = (score?['value'] as num?)?.toInt();
    if (value == null) {
      return const EligibilityResult(status: EligibilityStatus.notEligible);
    }
    final max = maxAmountFor(value);
    if (max == 0) {
      return const EligibilityResult(status: EligibilityStatus.notEligible);
    }
    final partial = value < 670;
    return EligibilityResult(
      status: partial
          ? EligibilityStatus.partiallyEligible
          : EligibilityStatus.eligible,
      offer: LoanOffer(
        partner: partner,
        maxAmount: max,
        termMonths: offerTermMonths,
        monthlyRepayment:
            LoanEstimate(principal: max, termMonths: offerTermMonths).monthly,
        interestLabel: interestLabel,
        pendingVerification: partial,
      ),
    );
  }

  @override
  Future<LoanDraft?> loadDraft() async => _draft;

  @override
  Future<void> saveDraft(LoanDraft draft) async => _draft = draft;

  @override
  Future<void> discardDraft() async => _draft = null;

  @override
  Future<LoanApplication> submit(LoanDraft draft) async {
    final purpose = draft.purpose;
    if (purpose == null) {
      throw const LoanException('Please choose what the loan is for.');
    }
    final estimate = LoanEstimate(
      principal: draft.amount,
      termMonths: draft.termMonths,
    );
    try {
      await _datasource.createLoan({
        'borrowerId': _uid,
        'partner': partner,
        'amount': draft.amount,
        'termMonths': draft.termMonths,
        'purpose': purpose.name,
        'stage': 'submitted',
        'interestLabel': interestLabel,
        'monthlyPayment': estimate.monthly,
        'totalRepayable': estimate.total,
        'paidAmount': 0,
      });
    } on FirebaseException {
      throw const LoanException(
        'We could not send your application. Please try again.',
      );
    }
    _draft = null;
    return LoanApplication(
      partner: partner,
      amount: draft.amount,
      termMonths: draft.termMonths,
      purpose: purpose,
      submittedOn: DateTime.now(),
    );
  }

  @override
  Future<LoanApplication?> fetchApplication() async {
    final loan = await _pendingApplication();
    if (loan == null) return null;
    return LoanApplication(
      partner: loan['partner'] as String? ?? partner,
      amount: (loan['amount'] as num).toInt(),
      termMonths: (loan['termMonths'] as num).toInt(),
      purpose: LoanPurpose.values.firstWhere(
        (p) => p.name == loan['purpose'],
        orElse: () => LoanPurpose.other,
      ),
      submittedOn:
          (loan['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> cancelApplication() async {
    final loan = await _pendingApplication();
    if (loan == null || loan['stage'] != 'submitted') {
      throw const LoanException(
        'This application is already being reviewed and cannot be withdrawn.',
      );
    }
    try {
      await _datasource.deleteLoan(loan['id'] as String);
    } on FirebaseException {
      throw const LoanException(
        'We could not withdraw your application. Please try again.',
      );
    }
  }
}
