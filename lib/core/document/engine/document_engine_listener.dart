abstract interface class DocumentEngineListener {
  void onReady();

  void onPageChanged(int? page);

  void onZoomChanged(double zoom);
}
