abstract interface class DocumentEngineController {
  int? get currentPage;
  int get pageCount;
  double get zoom;

  Stream<int?> get currentPageStream;
  Stream<double> get zoomStream;

  Future<void> goToPage(int page);

  Future<void> zoomIn();
  Future<void> zoomOut();

  Future<void> fitWidth();
  Future<void> fitPage();

  Future<void> nextPage();
  Future<void> previousPage();

  Future<void> dispose();
}