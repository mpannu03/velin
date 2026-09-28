import 'document_type.dart';

export 'document_repository.dart';
export 'document_type.dart';

class Document {
  Document({
    required this.path, 
    required this.type
  }) : id = _generateId();

  final String id;
  final String path;
  final DocumentType type;

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  @override
  String toString() => 'Document(id: $id, path: $path, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document &&
        other.id == id &&
        other.path == path &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, path, type);
}