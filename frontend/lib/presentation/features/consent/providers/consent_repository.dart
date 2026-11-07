import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';

// TEMP: swap the implementation when the backend repository is ready.
abstract class ConsentRepository {
  /// CREATE a consent record.
  Future<ConsentRecord> grantConsent(String type);

  /// READ a saved consent record.
  Future<ConsentRecord?> getConsent(String type);

  /// UPDATE a consent record as revoked.
  Future<ConsentRecord> revokeConsent(String type);

  Future<MomoConnectionResult> connectMomo();
}

class MockConsentRepository implements ConsentRepository {
  MockConsentRepository({
    this.outcome = MomoOutcome.eligible,
    this.delay = const Duration(seconds: 2),
  });

  final MomoOutcome outcome;
  final Duration delay;
  final Map<String, ConsentRecord> _records = {};

  @override
  Future<ConsentRecord> grantConsent(String type) async {
    final record = ConsentRecord(
      type: type,
      granted: true,
      grantedAt: DateTime.now(),
    );
    _records[type] = record;
    return record;
  }

  @override
  Future<ConsentRecord?> getConsent(String type) async => _records[type];

  @override
  Future<ConsentRecord> revokeConsent(String type) async {
    final existing = _records[type];
    if (existing == null) {
      throw StateError('No consent to revoke for $type');
    }
    final revoked = existing.revoke(DateTime.now());
    _records[type] = revoked;
    return revoked;
  }

  @override
  Future<MomoConnectionResult> connectMomo() async {
    await Future<void>.delayed(delay);
    if (outcome == MomoOutcome.connectionError) {
      throw const MomoConnectionException('The connection timed out.');
    }
    return MomoConnectionResult(
      account: const MomoAccount(maskedNumber: '078 ••• ••67'),
      eligible: outcome == MomoOutcome.eligible,
    );
  }
}
