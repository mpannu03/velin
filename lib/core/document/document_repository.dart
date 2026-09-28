import 'package:velin/core/result/result.dart';

import 'document.dart';

abstract interface class DocumentRepository {
  Result<Document> open(String path, DocumentType type);

  Result<void> close(String id);

  Document? get(String id);

  Stream<List<Document>> watch();
}