import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/data/datasources/loan_datasource.dart';
import 'package:staki_mobile/data/repositories/firestore_loan_repository.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/scoring_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_repository.dart';

/// Loans are read from and written to Firestore for a signed-in borrower.
/// With nobody signed in the in-memory repository keeps the screens usable.
/// To preview another L01 state, use for example
/// MockLoanRepository(status: EligibilityStatus.partiallyEligible).
final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final skipped = ref.watch(assessmentSkippedProvider);
  if (user == null || skipped) return MockLoanRepository();
  return FirestoreLoanRepository(
    datasource: LoanDatasource(ref.watch(firestoreProvider)),
    uid: user.uid,
  );
});

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
        ..invalidate(applicationProvider)
        // Home and the Loans tab show the newest loan: reload it.
        ..invalidate(loanAccountProvider);
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
        ..invalidate(applicationProvider)
        ..invalidate(loanAccountProvider);
      return true;
    } on Exception {
      return false;
    }
  }
}

final loanFlowProvider = NotifierProvider<LoanFlowController, LoanDraft>(
  LoanFlowController.new,
);
