import 'dart:async';

import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Map<String, Document> _documents = {};

  final StreamController<List<Document>> _controller =
      StreamController<List<Document>>.broadcast();

  bool _disposed = false;

  @override
  Result<Document> open(String path, DocumentType type) {
    try {
      final document = Document(path: path, type: type);
      _documents[document.id] = document;
      _emit();
      return Success(document);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  @override
  Result<void> close(String id) {
    try {
      _documents.remove(id);
      _emit();
      return const Success<void>(null);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  @override
  Document? get(String id) => _documents[id];

  @override
  Stream<List<Document>> watch() async* {
    // Emit current state immediately so subscribers don't see an empty list.
    yield List.unmodifiable(_documents.values);
    yield* _controller.stream;
  }

  void _emit() {
    if (_disposed) return;
    _controller.add(List.unmodifiable(_documents.values));
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller.close();
  }
}