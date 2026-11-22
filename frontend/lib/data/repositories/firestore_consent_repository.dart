import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/data/datasources/consent_datasource.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_repository.dart';

/// Real consent storage on Firestore (collection `consents`).
///
/// connectMomo() has no backend yet (momoAccounts is server-only), so it
/// is delegated to 'momoConnector', the mock by default. Replace it when
/// the MoMo verification service exists.
class FirestoreConsentRepository implements ConsentRepository {
  FirestoreConsentRepository({
    required ConsentDatasource datasource,
    required String? Function() currentUid,
    ConsentRepository? momoConnector,
  })  : _datasource = datasource,
        _currentUid = currentUid,
        _momoConnector = momoConnector ?? MockConsentRepository();

  final ConsentDatasource _datasource;
  final String? Function() _currentUid;
  final ConsentRepository _momoConnector;

  String _uid() {
    final uid = _currentUid();
    if (uid == null) throw StateError('No signed-in user.');
    return uid;
  }

  ConsentRecord _toRecord(Map<String, dynamic> data) {
    final granted = data['granted'] == true;
    final grantedAt = (data['grantedAt'] as Timestamp?)?.toDate();
    final revokedAt = (data['revokedAt'] as Timestamp?)?.toDate();
    return ConsentRecord(
      type: data['type'] as String,
      granted: granted,
      grantedAt: grantedAt ?? DateTime.now(),
      revokedAt: granted ? null : (revokedAt ?? DateTime.now()),
    );
  }

  @override
  Future<ConsentRecord> grantConsent(String type) async {
    final uid = _uid();
    final latest = await _datasource.getLatest(uid, type);
    // Already granted: do not create a duplicate ledger entry.
    if (latest != null && latest['granted'] == true) return _toRecord(latest);
    return _toRecord(await _datasource.grant(uid, type));
  }

  @override
  Future<ConsentRecord?> getConsent(String type) async {
    final latest = await _datasource.getLatest(_uid(), type);
    return latest == null ? null : _toRecord(latest);
  }

  @override
  Future<ConsentRecord> revokeConsent(String type) async {
    final latest = await _datasource.getLatest(_uid(), type);
    if (latest == null || latest['granted'] != true) {
      throw StateError('No consent to revoke for $type');
    }
    return _toRecord(await _datasource.revoke(latest['id'] as String));
  }

  @override
  Future<MomoConnectionResult> connectMomo() => _momoConnector.connectMomo();
}
