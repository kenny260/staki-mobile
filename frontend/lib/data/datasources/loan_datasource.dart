import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes the borrower's own loan records. Every query filters on
/// borrowerId, because firestore.rules only lets a borrower read their own
/// loans and repayments. Each map carries its document id under 'id'.
class LoanDatasource {
  LoanDatasource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _loans =>
      _db.collection('loans');
  CollectionReference<Map<String, dynamic>> get _repayments =>
      _db.collection('repayments');

  Map<String, dynamic> _withId(DocumentSnapshot<Map<String, dynamic>> doc) =>
      {'id': doc.id, ...?doc.data()};

  /// The borrower's loans, newest first.
  Future<List<Map<String, dynamic>>> loansOf(String uid) async {
    final snap = await _loans
        .where('borrowerId', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .get();
    return snap.docs.map(_withId).toList();
  }

  /// The borrower's Credit Passport, written by the scoring API.
  Future<Map<String, dynamic>?> scoreOf(String uid) async {
    final doc = await _db.collection('scores').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<Map<String, dynamic>> createLoan(Map<String, dynamic> data) async {
    final ref = await _loans.add({
      ...data,
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _withId(await ref.get());
  }

  /// Allowed by the rules only while the loan is still 'submitted'.
  Future<void> deleteLoan(String loanId) => _loans.doc(loanId).delete();

  Future<List<Map<String, dynamic>>> repaymentsOf(
    String uid,
    String loanId,
  ) async {
    final snap = await _repayments
        .where('borrowerId', isEqualTo: uid)
        .where('loanId', isEqualTo: loanId)
        .get();
    return snap.docs.map(_withId).toList();
  }

  Future<Map<String, dynamic>> createRepayment(
    Map<String, dynamic> data,
  ) async {
    final ref = await _repayments.add({
      ...data,
      'paidAt': FieldValue.serverTimestamp(),
    });
    return _withId(await ref.get());
  }
}
