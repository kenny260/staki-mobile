import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';

// TEMP: swap the implementation when the Firestore/Storage repository exists.
abstract class DocumentRepository {
  /// READ the user's documents.
  Future<List<DocumentItem>> fetchAll();

  /// CREATE / UPDATE: upload a file and save its record.
  Future<DocumentItem> upload(String id, PickedDocument file);

  /// DELETE the file and its record.
  Future<void> delete(String id);
}

class MockDocumentRepository implements DocumentRepository {
  MockDocumentRepository({
    this.delay = const Duration(seconds: 2),
    this.failUploads = false,
  });

  final Duration delay;

  /// Set to true to preview the upload error state.
  final bool failUploads;

  final List<DocumentItem> _items = [
    const DocumentItem(
      id: 'national_id',
      title: 'National ID',
      requirement: DocumentRequirement.mandatory,
      status: DocumentStatus.verified,
      fileName: 'national_id.jpg',
    ),
    const DocumentItem(
      id: 'momo_statement',
      title: 'MTN MoMo Statement',
      requirement: DocumentRequirement.mandatory,
      status: DocumentStatus.needsAttention,
      fileName: 'momo_statement.jpg',
      note: 'Document is blurry. Please retake.',
    ),
    const DocumentItem(
      id: 'business_registration',
      title: 'Business Registration (RDB)',
      requirement: DocumentRequirement.mandatory,
      status: DocumentStatus.underReview,
      fileName: 'rdb_certificate.pdf',
    ),
    const DocumentItem(
      id: 'bank_statement',
      title: 'Bank Statement',
      requirement: DocumentRequirement.recommended,
    ),
    const DocumentItem(
      id: 'proof_of_enrollment',
      title: 'Proof of Enrollment',
      requirement: DocumentRequirement.optional,
    ),
  ];

  int _indexOf(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw const DocumentException('Document not found.');
    }
    return index;
  }

  @override
  Future<List<DocumentItem>> fetchAll() async => List.of(_items);

  @override
  Future<DocumentItem> upload(String id, PickedDocument file) async {
    await Future<void>.delayed(delay);
    if (failUploads) {
      throw const DocumentException(
        "We couldn't upload this file. Please try again.",
      );
    }
    final index = _indexOf(id);
    final saved = _items[index].uploaded(file.name);
    _items[index] = saved;
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    final index = _indexOf(id);
    _items[index] = _items[index].removed();
  }
}
