import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document_type.dart';

void main() {
  group('DocumentType', () {
    test('returns supported file extensions', () {
      expect(
        DocumentType.pdf.fileExtensions,
        ['pdf'],
      );
    });

    group('fromPath', () {
      test('returns pdf for a pdf path', () {
        expect(
          DocumentType.fromPath('/documents/file.pdf'),
          DocumentType.pdf,
        );
      });

      test('is case insensitive', () {
        expect(
          DocumentType.fromPath('/documents/file.PDF'),
          DocumentType.pdf,
        );
      });

      test('returns null for unsupported extension', () {
        expect(
          DocumentType.fromPath('/documents/file.txt'),
          isNull,
        );
      });
    });
  });
}