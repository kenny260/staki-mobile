import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_providers.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_repository.dart';

/// Stands in for Firestore: the test pushes what the listener would see.
class _LiveDocuments extends MockDocumentRepository {
  _LiveDocuments() : super(delay: Duration.zero);

  final records = StreamController<List<DocumentItem>>();

  @override
  Stream<List<DocumentItem>> watchAll() => records.stream;
}

const _verifiedId = DocumentItem(
  id: 'national_id',
  title: 'National ID',
  requirement: DocumentRequirement.mandatory,
  status: DocumentStatus.verified,
  fileName: 'national_id.jpg',
);

const _noId = DocumentItem(
  id: 'national_id',
  title: 'National ID',
  requirement: DocumentRequirement.mandatory,
);

void main() {
  test('a record deleted in the Console disappears from My Documents',
      () async {
    final repo = _LiveDocuments();
    addTearDown(repo.records.close);
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(documentsControllerProvider, (_, __) {});

    // Offline cache first: the old, verified record.
    repo.records.add([_verifiedId]);
    final first = await container.read(documentsControllerProvider.future);
    expect(first.single.status, DocumentStatus.verified);

    // The server answers: the record is gone.
    repo.records.add([_noId]);
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(documentsControllerProvider).requireValue.single.status,
      DocumentStatus.notUploaded,
    );
  });

  test('a listener error before the first list shows the error state',
      () async {
    final repo = _LiveDocuments();
    addTearDown(repo.records.close);
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(documentsControllerProvider, (_, __) {});

    repo.records.addError(StateError('offline'));
    await expectLater(
      container.read(documentsControllerProvider.future),
      throwsStateError,
    );
  });
}
