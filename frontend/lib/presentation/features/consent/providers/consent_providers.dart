import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/data/datasources/consent_datasource.dart';
import 'package:staki_mobile/data/repositories/firestore_consent_repository.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_repository.dart';

/// Consent records are saved to Firestore `consents` for a signed-in user.
/// With nobody signed in (rules would reject the write) the in-memory
/// repository keeps the flow usable. To preview a MoMo result screen, use
/// MockConsentRepository(outcome: MomoOutcome.notEligible) or
/// MockConsentRepository(outcome: MomoOutcome.connectionError).
final consentRepositoryProvider = Provider<ConsentRepository>((ref) {
  // Rebuilds when the user signs in or out.
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return MockConsentRepository();
  return FirestoreConsentRepository(
    datasource: ConsentDatasource(ref.watch(firestoreProvider)),
    currentUid: () => user.uid,
  );
});

class ConsentController extends Notifier<ConsentFlowState> {
  @override
  ConsentFlowState build() => const ConsentFlowState();

  ConsentRepository get _repository => ref.read(consentRepositoryProvider);

  /// Called when the user has scrolled to the end of the terms (O02).
  void markTermsRead() {
    if (state.termsRead) return;
    state = state.copyWith(termsRead: true);
  }

  /// CREATE: save the user's consent with a timestamp.
  Future<void> agreeAndGrantConsent() async {
    final record = await _repository.grantConsent(momoConsentType);
    state = state.copyWith(consent: record);
  }

  /// READ: load a saved consent, for example after an app restart.
  Future<void> loadConsent() async {
    final record = await _repository.getConsent(momoConsentType);
    if (record != null) {
      state = state.copyWith(consent: record);
    }
  }

  /// UPDATE: revoke consent and clear the MoMo connection.
  /// The Data Permissions screen (Section 10) will call this.
  Future<void> revokeConsent() async {
    final record = await _repository.revokeConsent(momoConsentType);
    state = ConsentFlowState(consent: record);
  }

  Future<void> connect() async {
    state = state.copyWith(status: ConnectionStatus.connecting);
    try {
      final result = await _repository.connectMomo();
      state = state.copyWith(
        status: ConnectionStatus.connected,
        account: result.account,
        eligible: result.eligible,
      );
    } on MomoConnectionException {
      state = state.copyWith(status: ConnectionStatus.failed);
    }
  }
}

final consentControllerProvider =
    NotifierProvider<ConsentController, ConsentFlowState>(
  ConsentController.new,
);
