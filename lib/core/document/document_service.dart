import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';

abstract interface class DocumentService {
  Future<Result<Document>> open();

  Result<void> close(Document document);

  Stream<List<Document>> watch();
}
