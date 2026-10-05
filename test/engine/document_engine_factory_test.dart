import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/engine/engine.dart';

void main() {
  const factory = DocumentEngineFactory();

  test('creates PdfDocumentEngine for pdf files', () {
    final document = Document(
      path: '/documents/example.pdf',
      type: DocumentType.pdf,
    );

    final engine = factory.create(document);

    expect(engine, isA<PdfDocumentEngine>());
    expect(engine.document, same(document));
  });

  test('throws UnsupportedError for unsupported file types', () {
    final document = Document(
      path: '/documents/example.txt',
      type: DocumentType.pdf,
    );

    expect(() => factory.create(document), throwsA(isA<UnsupportedError>()));
  });
}
