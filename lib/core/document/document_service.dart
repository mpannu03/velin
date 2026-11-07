import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';

abstract interface class DocumentService {
  /// Lets the user pick a document and opens it.
  ///
  /// `Success(null)` means the user cancelled the picker.
  Future<Result<Document?>> open();

  /// Fails with `FileNotFoundFailure` when the file was moved or deleted
  /// since it was last opened.
  Future<Result<Document>> openRecent(RecentDocument recentDocument);

  Result<void> close(Document document);

  Stream<List<Document>> watch();
}
