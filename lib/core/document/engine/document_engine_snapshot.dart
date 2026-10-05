class DocumentEngineSnapshot {
  const DocumentEngineSnapshot({
    required this.currentPage,
    required this.pageCount,
    required this.zoom,
  });

  final int? currentPage;
  final int pageCount;
  final double zoom;
}
