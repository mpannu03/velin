import 'package:velin/core/document/document.dart';

class PdfDocumentRepository implements DocumentRepository {
  final Map<String, Document> _documents = {};

  @override
  Document open(String path) {
    final document = Document(
      path: path,
      type: DocumentType.pdf,
    );

    _documents[document.id] = document;

    return document;
  }

  @override
  Document? get(String id) {
    return _documents[id];
  }

  @override
  void close(String id) {
    _documents.remove(id);
  }
}