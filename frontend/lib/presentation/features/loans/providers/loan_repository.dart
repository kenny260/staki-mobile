import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';

// TEMP: swap the implementation when the Firestore repository exists.
abstract class LoanRepository {
  Future<EligibilityResult> fetchEligibility();

  /// READ the saved draft.
  Future<LoanDraft?> loadDraft();

  /// CREATE / UPDATE the draft.
  Future<void> saveDraft(LoanDraft draft);

  /// DELETE the draft.
  Future<void> discardDraft();

  /// CREATE the application from a draft.
  Future<LoanApplication> submit(LoanDraft draft);

  /// READ the submitted application.
  Future<LoanApplication?> fetchApplication();

  /// DELETE the submitted application.
  Future<void> cancelApplication();
}

class MockLoanRepository implements LoanRepository {
  MockLoanRepository({
    this.status = EligibilityStatus.eligible,
    this.delay = const Duration(milliseconds: 400),
  });

  /// Change this to preview each L01 state.
  final EligibilityStatus status;
  final Duration delay;

  LoanDraft? _draft;
  LoanApplication? _application;

  static const _eligibleOffer = LoanOffer(
    partner: 'Bank of Kigali',
    maxAmount: 1200000,
    termMonths: 6,
    monthlyRepayment: 215000,
    interestLabel: '1.5% monthly',
    pendingVerification: false,
  );

  static const _partialOffer = LoanOffer(
    partner: 'Bank of Kigali',
    maxAmount: 500000,
    termMonths: 6,
    monthlyRepayment: 92000,
    interestLabel: '1.5% monthly',
    pendingVerification: true,
  );

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<EligibilityResult> fetchEligibility() async {
    await _wait();
    if (_application != null) {
      return const EligibilityResult(status: EligibilityStatus.underReview);
    }
    switch (status) {
      case EligibilityStatus.eligible:
        return const EligibilityResult(
          status: EligibilityStatus.eligible,
          offer: _eligibleOffer,
        );
      case EligibilityStatus.partiallyEligible:
        return const EligibilityResult(
          status: EligibilityStatus.partiallyEligible,
          offer: _partialOffer,
        );
      case EligibilityStatus.notEligible:
        return const EligibilityResult(status: EligibilityStatus.notEligible);
      case EligibilityStatus.underReview:
        return const EligibilityResult(status: EligibilityStatus.underReview);
    }
  }

  @override
  Future<LoanDraft?> loadDraft() async {
    await _wait();
    return _draft;
  }

  @override
  Future<void> saveDraft(LoanDraft draft) async {
    await _wait();
    _draft = draft;
  }

  @override
  Future<void> discardDraft() async {
    await _wait();
    _draft = null;
  }

  @override
  Future<LoanApplication> submit(LoanDraft draft) async {
    await _wait();
    final purpose = draft.purpose;
    if (purpose == null) {
      throw const LoanException('Please choose what the loan is for.');
    }
    final application = LoanApplication(
      partner: _eligibleOffer.partner,
      amount: draft.amount,
      termMonths: draft.termMonths,
      purpose: purpose,
      submittedOn: DateTime.now(),
    );
    _application = application;
    _draft = null;
    return application;
  }

  @override
  Future<LoanApplication?> fetchApplication() async {
    await _wait();
    return _application;
  }

  @override
  Future<void> cancelApplication() async {
    await _wait();
    _application = null;
  }
}
