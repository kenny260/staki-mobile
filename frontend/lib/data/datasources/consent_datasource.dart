import 'package:cloud_firestore/cloud_firestore.dart';

/// Talks to the top-level `consents` collection. Matches firestore.rules:
///  - create: type 'momo', granted true, revokedAt null, userId == auth uid
///  - revoke: update ONLY granted -> false and revokedAt -> timestamp
/// Every method returns the document data with its id under 'id'.
class ConsentDatasource {
  ConsentDatasource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('consents');

  Map<String, dynamic> _withId(DocumentSnapshot<Map<String, dynamic>> doc) =>
      {'id': doc.id, ...?doc.data()};

  Future<Map<String, dynamic>> grant(String uid, String type) async {
    final ref = await _col.add({
      'userId': uid,
      'type': type,
      'granted': true,
      'revokedAt': null,
      'grantedAt': FieldValue.serverTimestamp(),
    });
    return _withId(await ref.get());
  }

  /// Newest consent of this type for the user, or null.
  /// The userId filter is REQUIRED or the rules reject the query. Sorting
  /// happens here so no composite index is needed.
  Future<Map<String, dynamic>?> getLatest(String uid, String type) async {
    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: type)
        .get();
    if (snap.docs.isEmpty) return null;

    Timestamp grantedAt(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
        d.data()['grantedAt'] as Timestamp? ?? Timestamp.now();

    final docs = snap.docs.toList()
      ..sort((a, b) => grantedAt(a).compareTo(grantedAt(b)));
    return _withId(docs.last);
  }

  Future<Map<String, dynamic>> revoke(String consentId) async {
    final ref = _col.doc(consentId);
    await ref.update({
      'granted': false,
      'revokedAt': FieldValue.serverTimestamp(),
    });
    return _withId(await ref.get());
  }
}
