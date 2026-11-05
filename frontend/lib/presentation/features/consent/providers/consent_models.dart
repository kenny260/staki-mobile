// TEMP: replace with domain entities once the backend team publishes them.

/// Value stored in the `type` field of a consent document.
const momoConsentType = 'momo';

/// What the mock repository does when the user connects MoMo.
enum MomoOutcome { eligible, notEligible, connectionError }

enum ConnectionStatus { idle, connecting, connected, failed }

class ConsentRecord {
  const ConsentRecord({
    required this.type,
    required this.granted,
    required this.grantedAt,
    this.revokedAt,
  });

  final String type;
  final bool granted;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  ConsentRecord revoke(DateTime at) => ConsentRecord(
        type: type,
        granted: false,
        grantedAt: grantedAt,
        revokedAt: at,
      );
}

class MomoAccount {
  const MomoAccount({required this.maskedNumber});

  final String maskedNumber;
}

class MomoConnectionResult {
  const MomoConnectionResult({required this.account, required this.eligible});

  final MomoAccount account;
  final bool eligible;
}

class MomoConnectionException implements Exception {
  const MomoConnectionException(this.message);

  final String message;
}

/// Everything the consent and MoMo screens need to know.
class ConsentFlowState {
  const ConsentFlowState({
    this.termsRead = false,
    this.consent,
    this.status = ConnectionStatus.idle,
    this.account,
    this.eligible,
  });

  final bool termsRead;
  final ConsentRecord? consent;
  final ConnectionStatus status;
  final MomoAccount? account;
  final bool? eligible;

  bool get momoConnected => status == ConnectionStatus.connected;

  ConsentFlowState copyWith({
    bool? termsRead,
    ConsentRecord? consent,
    ConnectionStatus? status,
    MomoAccount? account,
    bool? eligible,
  }) {
    return ConsentFlowState(
      termsRead: termsRead ?? this.termsRead,
      consent: consent ?? this.consent,
      status: status ?? this.status,
      account: account ?? this.account,
      eligible: eligible ?? this.eligible,
    );
  }
}
