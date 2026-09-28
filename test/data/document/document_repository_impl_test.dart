import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/data/document/document_repository_impl.dart';

void main() {
  late DocumentRepositoryImpl repository;

  setUp(() {
    repository = DocumentRepositoryImpl();
  });

  group('open', () {
    test('creates and stores a document', () {
      final result = repository.open(
        '/documents/test.pdf',
        DocumentType.pdf,
      );

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
      final result = repository.open(
        '/documents/test.pdf',
        DocumentType.pdf,
      );

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
}