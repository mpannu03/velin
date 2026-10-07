import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';

abstract interface class DocumentService {
  Future<Result<Document>> open();

  Future<Result<Document>> openRecent(RecentDocument recentDocument);

  Result<void> close(Document document);

  Stream<List<Document>> watch();
}
