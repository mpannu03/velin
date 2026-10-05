import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/data/document/document_repository_impl.dart';

void main() {
  late DocumentRepositoryImpl repository;

  setUp(() {
    repository = DocumentRepositoryImpl();
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('open', () {
    test('creates and stores a document', () {
      final result = repository.open('/documents/test.pdf', DocumentType.pdf);

      expect(result, isA<Success<Document>>());

      final document = (result as Success<Document>).data;

      expect(document.path, '/documents/test.pdf');
      expect(document.type, DocumentType.pdf);
      expect(repository.get(document.id), same(document));
    });
  });

  group('get', () {
    test('returns null for unknown id', () {
      expect(repository.get('unknown-id'), isNull);
    });
  });

  group('close', () {
    test('removes the document', () {
      final result = repository.open('/documents/test.pdf', DocumentType.pdf);

      final document = (result as Success<Document>).data;
      final closeResult = repository.close(document.id);

      expect(closeResult, const Success<void>(null));
      expect(repository.get(document.id), isNull);
    });

    test('succeeds when document does not exist', () {
      final result = repository.close('unknown-id');

      expect(result, const Success<void>(null));
    });
  });

  group('watch', () {
    test('emits documents when a document is opened', () async {
      final future = repository.watch().first;

      repository.open('/documents/test.pdf', DocumentType.pdf);

      final documents = await future;

      expect(documents, hasLength(1));
      expect(documents.single.path, '/documents/test.pdf');
    });

    test('emits documents when a document is closed', () async {
      final result = repository.open('/documents/test.pdf', DocumentType.pdf);

      final document = (result as Success<Document>).data;
      final future = repository.watch().first;

      repository.close(document.id);

      final documents = await future;

      expect(documents, isEmpty);
    });

    test('emits all currently opened documents', () async {
      final first = repository.open('/documents/first.pdf', DocumentType.pdf);

      repository.open('/documents/second.pdf', DocumentType.pdf);

      final future = repository.watch().first;

      final firstDocument = (first as Success<Document>).data;

      repository.close(firstDocument.id);

      final documents = await future;

      expect(documents, hasLength(1));
      expect(documents.single.path, '/documents/second.pdf');
    });
  });
}
