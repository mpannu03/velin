import 'document.dart';

abstract interface class DocumentRepository {
  Document open(String path);

  Document? get(String id);

  void close(String id);
}