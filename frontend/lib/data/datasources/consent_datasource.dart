import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches firestore.rules for /consents:
///  - create: type 'momo', granted true, revokedAt null, userId == auth uid
///  - revoke: update ONLY granted -> false and revokedAt -> timestamp
/// Check presentation/features/consent/providers/consent_repository.dart
/// first; merge into it instead of duplicating if it already writes these.
class ConsentDatasource {
  ConsentDatasource(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('consents');

  /// Returns the new consent document id.
  Future<String> grantMomo(String uid) async {
    final ref = await _col.add({
      'userId': uid,
      'type': 'momo',
      'granted': true,
      'revokedAt': null,
      'grantedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> revoke(String consentId) => _col.doc(consentId).update({
        'granted': false,
        'revokedAt': FieldValue.serverTimestamp(),
      });

  /// The userId filter is REQUIRED, otherwise the rules reject the query.
  Stream<List<Map<String, dynamic>>> watchMine(String uid) => _col
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
}
