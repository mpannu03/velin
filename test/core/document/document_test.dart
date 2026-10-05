import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document.dart';

void main() {
  group('Document', () {
    test('creates document with path and type', () {
      final document = Document(
        path: '/documents/test.pdf',
        type: DocumentType.pdf,
      );

      expect(document.path, '/documents/test.pdf');
      expect(document.type, DocumentType.pdf);
      expect(document.id, isNotEmpty);
    });

    test('generates a unique id for each document', () {
      final first = Document(
        path: '/documents/test.pdf',
        type: DocumentType.pdf,
      );
      final second = Document(
        path: '/documents/test.pdf',
        type: DocumentType.pdf,
      );

      expect(first.id, isNot(second.id));
    });

    test('documents with the same id, path, and type are equal', () {
      final document = Document(
        path: '/documents/test.pdf',
        type: DocumentType.pdf,
      );

      final copy = Document(path: document.path, type: document.type);

      expect(copy, isNot(equals(document)));
    });

    test('toString contains document information', () {
      final document = Document(
        path: '/documents/test.pdf',
        type: DocumentType.pdf,
      );

      expect(
        document.toString(),
        'Document('
        'id: ${document.id}, '
        'path: /documents/test.pdf, '
        'type: DocumentType.pdf'
        ')',
      );
    });
  });
}
