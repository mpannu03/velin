import 'package:velin/core/document/document.dart';

class RecentDocument {
  const RecentDocument({
    required this.path,
    required this.pageCount,
    required this.currentPage,
    required this.lastOpenedAt,
    required this.documentType,
  });

  final String path;
  final int pageCount;
  final int currentPage;
  final DateTime lastOpenedAt;
  final DocumentType documentType;

  @override
  bool operator ==(covariant RecentDocument other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.pageCount == pageCount &&
        other.currentPage == currentPage &&
        other.lastOpenedAt == lastOpenedAt &&
        other.documentType == documentType;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        pageCount.hashCode ^
        currentPage.hashCode ^
        lastOpenedAt.hashCode ^
        documentType.hashCode;
  }
}
