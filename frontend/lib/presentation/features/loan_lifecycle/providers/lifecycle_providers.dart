import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/data/datasources/loan_datasource.dart';
import 'package:staki_mobile/data/repositories/firestore_lifecycle_repository.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_repository.dart';

/// The current loan is read from Firestore for a signed-in borrower, and
/// repayments are saved there. With nobody signed in the in-memory
/// repository keeps the screens usable. To preview another stage, use for
/// example MockLifecycleRepository(stage: LoanStage.repaymentDue).
final lifecycleRepositoryProvider = Provider<LifecycleRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return MockLifecycleRepository();
  return FirestoreLifecycleRepository(
    datasource: LoanDatasource(ref.watch(firestoreProvider)),
    uid: user.uid,
  );
});

/// The payment method chosen on L08.
final selectedMethodProvider = StateProvider<PayMethod>(
  (ref) => PayMethod.momo,
);

/// The receipt shown on L10.
final lastReceiptProvider = StateProvider<RepaymentReceipt?>((ref) => null);

class LoanAccountController extends AsyncNotifier<LoanAccount> {
  LifecycleRepository get _repository => ref.read(lifecycleRepositoryProvider);

  @override
  Future<LoanAccount> build() => _repository.fetchLoan();

  /// UPDATE: sign the agreement.
  Future<bool> acceptAgreement() async {
    try {
      state = AsyncData(await _repository.acceptAgreement());
      return true;
    } on Exception {
      return false;
    }
  }

  /// UPDATE: open the loan dashboard after disbursement.
  Future<bool> acknowledgeDisbursed() async {
    try {
      state = AsyncData(await _repository.acknowledgeDisbursed());
      return true;
    } on Exception {
      return false;
    }
  }

  /// CREATE a repayment. Returns null if it failed.
  Future<RepaymentReceipt?> repay(PayMethod method) async {
    try {
      final receipt = await _repository.repay(method);
      state = AsyncData(await _repository.fetchLoan());
      ref.read(lastReceiptProvider.notifier).state = receipt;
      return receipt;
    } on Exception {
      return null;
    }
  }
}

final loanAccountProvider =
    AsyncNotifierProvider<LoanAccountController, LoanAccount>(
  LoanAccountController.new,
);
