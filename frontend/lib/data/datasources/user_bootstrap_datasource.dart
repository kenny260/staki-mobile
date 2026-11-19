import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';

/// Creates users/{uid} once. Matches firestore.rules:
/// create needs role in ['borrower','lender']; role can never change later.
/// profiles/{uid} is NOT created here: it needs borrowerType + answers
/// from the onboarding questionnaire.
class UserBootstrapDatasource {
  UserBootstrapDatasource(this._db);
  final FirebaseFirestore _db;

  /// Returns true if the document was created, false if it already existed.
  Future<bool> ensureUserDocument(AppUser user, {required String role}) async {
    if (role != 'borrower' && role != 'lender') {
      throw ArgumentError.value(role, 'role', 'must be borrower or lender');
    }
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get(); // allowed: owner read, even if missing
    if (snap.exists) return false; // a set() here would count as an update

    await ref.set({
      'role': role,
      'email': user.email,
      'displayName': user.displayName,
      'provider': user.provider,
      'createdAt': FieldValue.serverTimestamp(),
      'fcmTokens': <String>[],
    });
    return true;
  }

  /// For push notifications (later sprint). Allowed by rules: role unchanged.
  Future<void> addFcmToken(String uid, String token) =>
      _db.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });

  Future<void> removeFcmToken(String uid, String token) =>
      _db.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
  Future<bool> userExists(String uid) async =>
      (await _db.collection('users').doc(uid).get()).exists;
}
