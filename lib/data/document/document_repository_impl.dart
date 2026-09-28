import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Map<String, Document> _documents = {};

  @override
  Result<Document> open(String path, DocumentType type) {
    try {
      final document = Document(
        path: path,
        type: type,
      );

      _documents[document.id] = document;

      return Success(document);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  @override
  Result<void> close(String id) {
    try {
      _documents.remove(id);

      return const Success(null);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  @override
  Document? get(String id) {
    return _documents[id];
  }
}