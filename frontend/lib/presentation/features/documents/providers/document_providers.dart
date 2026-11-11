import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_picker.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_repository.dart';

// TEMP mock. To preview the upload error, use:
// MockDocumentRepository(failUploads: true)
final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => MockDocumentRepository(),
);

final documentPickerProvider = Provider<DocumentPicker>(
  (ref) => pickFromDevice,
);

/// The file waiting on the preview screen (D04).
final pendingUploadProvider = StateProvider<PendingUpload?>((ref) => null);

class DocumentsController extends AsyncNotifier<List<DocumentItem>> {
  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  @override
  Future<List<DocumentItem>> build() => _repository.fetchAll();

  void _replace(String id, DocumentItem Function(DocumentItem) change) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final item in current)
        if (item.id == id) change(item) else item,
    ]);
  }

  /// CREATE / UPDATE: shows "Uploading", then "Under review".
  /// On failure the card shows "Needs attention" with a polite note.
  Future<void> upload(String id, PickedDocument file) async {
    _replace(id, (i) => i.withStatus(DocumentStatus.uploading));
    try {
      final saved = await _repository.upload(id, file);
      _replace(id, (_) => saved);
    } on Exception catch (e) {
      final message = e is DocumentException
          ? e.message
          : 'Upload failed. Please try again.';
      _replace(
        id,
        (i) => i.withStatus(DocumentStatus.needsAttention, note: message),
      );
    }
  }

  /// DELETE: removes the file and resets the card.
  Future<void> remove(String id) async {
    await _repository.delete(id);
    _replace(id, (i) => i.removed());
  }
}

final documentsControllerProvider =
    AsyncNotifierProvider<DocumentsController, List<DocumentItem>>(
  DocumentsController.new,
);
