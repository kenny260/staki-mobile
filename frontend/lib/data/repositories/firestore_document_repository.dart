import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staki_mobile/data/datasources/cloudinary_datasource.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_repository.dart';

/// The documents every borrower is asked for. Each one is a card on D01.
const List<DocumentItem> documentCatalog = [
  DocumentItem(
    id: 'national_id',
    title: 'National ID',
    requirement: DocumentRequirement.mandatory,
  ),
  DocumentItem(
    id: 'momo_statement',
    title: 'MTN MoMo Statement',
    requirement: DocumentRequirement.mandatory,
  ),
  DocumentItem(
    id: 'business_registration',
    title: 'Business Registration (RDB)',
    requirement: DocumentRequirement.mandatory,
  ),
  DocumentItem(
    id: 'bank_statement',
    title: 'Bank Statement',
    requirement: DocumentRequirement.recommended,
  ),
  DocumentItem(
    id: 'proof_of_enrollment',
    title: 'Proof of Enrollment',
    requirement: DocumentRequirement.optional,
  ),
];

/// Files go to Cloudinary; the record (link + review status) goes to
/// Firestore at `users/{uid}/documents/{documentId}`.
class FirestoreDocumentRepository implements DocumentRepository {
  FirestoreDocumentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    CloudinaryDataSource? cloudinary,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _cloudinary = cloudinary ?? CloudinaryDataSource();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CloudinaryDataSource _cloudinary;

  /// TEMP: signs in anonymously until the real login flow exists, so
  /// Firestore rules have a user to check against.
  Future<String> _uid() async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    if (user == null) {
      throw const DocumentException('Please sign in to manage documents.');
    }
    return user.uid;
  }

  Future<CollectionReference<Map<String, dynamic>>> _collection() async =>
      _firestore.collection('users').doc(await _uid()).collection('documents');

  @override
  Future<List<DocumentItem>> fetchAll() async {
    final snapshot = await (await _collection()).get();
    final records = {for (final doc in snapshot.docs) doc.id: doc.data()};
    return [
      for (final item in documentCatalog) _merge(item, records[item.id]),
    ];
  }

  @override
  Future<DocumentItem> upload(String id, PickedDocument file) async {
    final item = _catalogItem(id);
    final uid = await _uid();

    final CloudinaryUpload uploaded;
    try {
      uploaded = await _cloudinary.uploadFile(
        filePath: file.path,
        folder: 'documents/$uid',
      );
    } on CloudinaryException catch (e) {
      throw DocumentException(e.message);
    }

    await (await _collection()).doc(id).set({
      'fileName': file.name,
      'url': uploaded.url,
      'publicId': uploaded.publicId,
      'resourceType': uploaded.resourceType,
      'bytes': uploaded.bytes,
      'status': DocumentStatus.underReview.name,
      'note': null,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    return item.uploaded(file.name);
  }

  /// Removes the record. The Cloudinary file stays until a server-side
  /// cleanup job deletes it (deleting needs the API secret).
  @override
  Future<void> delete(String id) async {
    _catalogItem(id);
    await (await _collection()).doc(id).delete();
  }

  DocumentItem _catalogItem(String id) => documentCatalog.firstWhere(
        (item) => item.id == id,
        orElse: () => throw const DocumentException('Document not found.'),
      );

  DocumentItem _merge(DocumentItem item, Map<String, dynamic>? record) {
    if (record == null) return item;
    final status = DocumentStatus.values.asNameMap()[record['status']] ??
        DocumentStatus.underReview;
    return DocumentItem(
      id: item.id,
      title: item.title,
      requirement: item.requirement,
      status: status,
      fileName: record['fileName'] as String?,
      note: record['note'] as String?,
    );
  }
}
