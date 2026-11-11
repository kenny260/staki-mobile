import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

// TEMP mock. To preview another L01 state, pass a status, for example:
// MockLoanRepository(status: EligibilityStatus.partiallyEligible)
// MockLoanRepository(status: EligibilityStatus.notEligible)
final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => MockLoanRepository(),
);

final eligibilityProvider = FutureProvider.autoDispose<EligibilityResult>(
  (ref) => ref.watch(loanRepositoryProvider).fetchEligibility(),
);

final applicationProvider = FutureProvider.autoDispose<LoanApplication?>(
  (ref) => ref.watch(loanRepositoryProvider).fetchApplication(),
);

class LoanFlowController extends Notifier<LoanDraft> {
  LoanRepository get _repository => ref.read(loanRepositoryProvider);

  @override
  LoanDraft build() => const LoanDraft();

  /// READ: loads a saved draft (or starts a fresh one).
  Future<void> start({required int maxAmount}) async {
    LoanDraft draft;
    try {
      draft = await _repository.loadDraft() ?? const LoanDraft();
    } on Exception {
      draft = const LoanDraft();
    }
    state = draft.copyWith(
      amount: draft.amount > maxAmount ? maxAmount : draft.amount,
    );
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void setTerm(int months) => state = state.copyWith(termMonths: months);

  void setPurpose(LoanPurpose purpose) =>
      state = state.copyWith(purpose: purpose);

  /// CREATE / UPDATE the draft. Returns false if it failed.
  Future<bool> saveDraft() async {
    try {
      await _repository.saveDraft(state);
      return true;
    } on Exception {
      return false;
    }
  }

  /// DELETE the draft.
  Future<bool> discardDraft() async {
    try {
      await _repository.discardDraft();
      state = const LoanDraft();
      return true;
    } on Exception {
      return false;
    }
  }

  /// CREATE the application. Returns null if it failed.
  Future<LoanApplication?> submit() async {
    try {
      final application = await _repository.submit(state);
      state = const LoanDraft();
      ref
        ..invalidate(eligibilityProvider)
        ..invalidate(applicationProvider);
      return application;
    } on Exception {
      return null;
    }
  }

  /// DELETE the submitted application.
  Future<bool> cancelApplication() async {
    try {
      await _repository.cancelApplication();
      ref
        ..invalidate(eligibilityProvider)
        ..invalidate(applicationProvider);
      return true;
    } on Exception {
      return false;
    }
  }
}

final loanFlowProvider = NotifierProvider<LoanFlowController, LoanDraft>(
  LoanFlowController.new,
);
