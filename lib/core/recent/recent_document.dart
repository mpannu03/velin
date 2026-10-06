class RecentDocument {
  const RecentDocument({
    required this.path,
    required this.pageCount,
    required this.currentPage,
    required this.lastOpenedAt,
  });

  final String path;
  final int pageCount;
  final int currentPage;
  final DateTime lastOpenedAt;

  @override
  bool operator ==(covariant RecentDocument other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.pageCount == pageCount &&
        other.currentPage == currentPage &&
        other.lastOpenedAt == lastOpenedAt;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        pageCount.hashCode ^
        currentPage.hashCode ^
        lastOpenedAt.hashCode;
  }
}
