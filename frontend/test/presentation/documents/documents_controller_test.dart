import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_providers.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_repository.dart';

ProviderContainer _container({bool failUploads = false}) {
  final container = ProviderContainer(
    overrides: [
      documentRepositoryProvider.overrideWithValue(
        MockDocumentRepository(
          delay: Duration.zero,
          failUploads: failUploads,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

DocumentItem _find(ProviderContainer container, String id) {
  final items = container.read(documentsControllerProvider).requireValue;
  return items.firstWhere((item) => item.id == id);
}

const _file = PickedDocument(name: 'new.pdf', path: '/tmp/new.pdf');

void main() {
  test('loads the five documents', () async {
    final container = _container();
    final items = await container.read(documentsControllerProvider.future);
    expect(items, hasLength(5));
    expect(items.first.status, DocumentStatus.verified);
  });

  test('upload moves a document to under review with its file name', () async {
    final container = _container();
    await container.read(documentsControllerProvider.future);
    await container
        .read(documentsControllerProvider.notifier)
        .upload('bank_statement', _file);
    final item = _find(container, 'bank_statement');
    expect(item.status, DocumentStatus.underReview);
    expect(item.fileName, 'new.pdf');
  });

  test('a failed upload shows needs attention with a note', () async {
    final container = _container(failUploads: true);
    await container.read(documentsControllerProvider.future);
    await container
        .read(documentsControllerProvider.notifier)
        .upload('bank_statement', _file);
    final item = _find(container, 'bank_statement');
    expect(item.status, DocumentStatus.needsAttention);
    expect(item.note, isNotNull);
  });

  test('remove resets the document', () async {
    final container = _container();
    await container.read(documentsControllerProvider.future);
    await container
        .read(documentsControllerProvider.notifier)
        .remove('business_registration');
    final item = _find(container, 'business_registration');
    expect(item.status, DocumentStatus.notUploaded);
    expect(item.fileName, isNull);
  });

  test('only under review or flagged documents can be removed', () async {
    final container = _container();
    await container.read(documentsControllerProvider.future);
    expect(_find(container, 'national_id').canRemove, isFalse);
    expect(_find(container, 'momo_statement').canRemove, isTrue);
  });
}
