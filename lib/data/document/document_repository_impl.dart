import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Map<String, Document> _documents = {};

  final StreamController<List<Document>> _controller =
      StreamController<List<Document>>.broadcast();

  final StreamController<Document> _activated =
      StreamController<Document>.broadcast();

  bool _disposed = false;

  @override
  Result<Document> open(String path, DocumentType type) {
    return Result.guardSync(() {
      // One document per file: the reader keys its views by path, and a
      // second copy of the same file would only confuse the user.
      // `p.equals` ignores case on Windows.
      final existing = _documents.values
          .where((document) => p.equals(document.path, path))
          .firstOrNull;

      if (existing != null) {
        _activate(existing);
        return existing;
      }

      final document = Document(path: path, type: type);
      _documents[document.id] = document;
      _emit();
      _activate(document);
      return document;
    });
  }

  @override
  Result<void> close(String id) {
    return Result.guardSync(() {
      _documents.remove(id);
      _emit();
    });
  }

  @override
  Document? get(String id) => _documents[id];

  @override
  Stream<List<Document>> watch() async* {
    // Emit current state immediately so subscribers don't see an empty list.
    yield List.unmodifiable(_documents.values);
    yield* _controller.stream;
  }

  @override
  Stream<Document> watchActivated() => _activated.stream;

  void _emit() {
    if (_disposed) return;
    _controller.add(List.unmodifiable(_documents.values));
  }

  void _activate(Document document) {
    if (_disposed) return;
    _activated.add(document);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller.close();
    await _activated.close();
  }
}
