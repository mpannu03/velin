import 'package:velin/core/result/result.dart';

import 'document.dart';

abstract interface class DocumentRepository {
  /// Opens the document at [path], or returns the already open document for
  /// that file. Either way the document is announced on [watchActivated].
  Result<Document> open(String path, DocumentType type);

  Result<void> close(String id);

  Document? get(String id);

  Stream<List<Document>> watch();

  /// Emits a document each time it is opened, including when an already
  /// open file is opened again, so the UI can bring it to the front.
  Stream<Document> watchActivated();
}
