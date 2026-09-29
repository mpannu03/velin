abstract interface class DocumentEngineController {
  int? get currentPage;

  int get pageCount;

  Stream<int?> get currentPageStream;

  Future<void> goToPage(int page);

  Future<void> zoomIn();

  Future<void> zoomOut();

  Future<void> fitWidth();

  Future<void> fitPage();

  Future<void> nextPage();

  Future<void> previousPage();
}