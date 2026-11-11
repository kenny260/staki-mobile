// TEMP: replace with domain entities once the backend team publishes them.

enum DocumentStatus {
  notUploaded,
  uploading,
  underReview,
  verified,
  needsAttention,
}

enum DocumentRequirement { mandatory, recommended, optional }

enum UploadSource { scan, camera, files, gallery }

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    required this.requirement,
    this.status = DocumentStatus.notUploaded,
    this.fileName,
    this.note,
  });

  final String id;
  final String title;
  final DocumentRequirement requirement;
  final DocumentStatus status;
  final String? fileName;
  final String? note;

  bool get canUpload =>
      status == DocumentStatus.notUploaded ||
      status == DocumentStatus.needsAttention;

  bool get canRemove =>
      fileName != null &&
      (status == DocumentStatus.underReview ||
          status == DocumentStatus.needsAttention);

  DocumentItem withStatus(DocumentStatus newStatus, {String? note}) {
    return DocumentItem(
      id: id,
      title: title,
      requirement: requirement,
      status: newStatus,
      fileName: fileName,
      note: note,
    );
  }

  DocumentItem uploaded(String name) {
    return DocumentItem(
      id: id,
      title: title,
      requirement: requirement,
      status: DocumentStatus.underReview,
      fileName: name,
    );
  }

  DocumentItem removed() {
    return DocumentItem(id: id, title: title, requirement: requirement);
  }
}

class PickedDocument {
  const PickedDocument({required this.name, required this.path});

  final String name;
  final String path;
}

/// The file the user picked, waiting on the preview screen.
class PendingUpload {
  const PendingUpload({required this.item, required this.file});

  final DocumentItem item;
  final PickedDocument file;
}

class DocumentException implements Exception {
  const DocumentException(this.message);

  final String message;
}
