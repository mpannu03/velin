abstract interface class DocumentEngineActions {
  Future<void> goToPage(int page);

  Future<void> zoomIn();
  Future<void> zoomOut();

  Future<void> fitWidth();
  Future<void> fitPage();

  Future<void> nextPage();
  Future<void> previousPage();
}
