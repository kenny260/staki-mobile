import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/data/repositories/firestore_document_repository.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_picker.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_repository.dart';

// Files upload to Cloudinary, records live in Firestore.
// For offline UI work or tests, override with MockDocumentRepository()
// (or MockDocumentRepository(failUploads: true) to preview the error state).
final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => FirestoreDocumentRepository(),
);

final documentPickerProvider = Provider<DocumentPicker>(
  (ref) => pickFromDevice,
);

/// The file waiting on the preview screen (D04).
final pendingUploadProvider = StateProvider<PendingUpload?>((ref) => null);

class DocumentsController extends AsyncNotifier<List<DocumentItem>> {
  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  /// Listens to the documents: the first list fills the screen, later
  /// ones (an upload, a remove, a change in the Console) replace it.
  @override
  Future<List<DocumentItem>> build() {
    final first = Completer<List<DocumentItem>>();
    final subscription = _repository.watchAll().listen(
      (items) {
        if (first.isCompleted) {
          state = AsyncData(items);
        } else {
          first.complete(items);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (first.isCompleted) {
          state = AsyncError(error, stack);
        } else {
          first.completeError(error, stack);
        }
      },
    );
    ref.onDispose(subscription.cancel);
    return first.future;
  }

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
