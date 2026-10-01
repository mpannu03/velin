import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfDocumentEngineActions implements DocumentEngineActions {
  PdfDocumentEngineActions(this._controller);

  final PdfViewerController _controller;

  static const _zoomStep = 0.2;

  @override
  Future<void> goToPage(int page) async {
    if (page < 1 || page > _controller.pageCount) {
      return;
    }

    final matrix = _controller.calcMatrixForPage(
      pageNumber: page,
    );

    await _controller.goTo(matrix);
  }

  @override
Future<void> zoomIn() async {
  return _zoomByStep(_zoomStep);
}

  @override
  Future<void> zoomOut() {
    return _zoomByStep(-_zoomStep);
  }

  @override
  Future<void> fitWidth() async {
    final pageNumber = _controller.pageNumber ?? 1;

    final matrix = _controller.calcMatrixFitWidthForPage(
      pageNumber: pageNumber,
    );

    if (matrix != null) {
      await _controller.goTo(matrix);
    }
  }

  @override
  Future<void> fitPage() async {
    final pageNumber = _controller.pageNumber ?? 1;

    final matrix = _controller.calcMatrixForFit(
      pageNumber: pageNumber,
    );

    if (matrix != null) {
      await _controller.goTo(matrix);
    }
  }

  @override
  Future<void> nextPage() {
    final page = _controller.pageNumber;

    if (page == null || page >= _controller.pageCount) {
      return Future.value();
    }

    return goToPage(page + 1);
  }

  @override
  Future<void> previousPage() {
    final page = _controller.pageNumber;

    if (page == null || page <= 1) {
      return Future.value();
    }

    return goToPage(page - 1);
  }

  Future<void> _zoomByStep(double step) async {
  final currentZoom = _controller.currentZoom;
  final newZoom = (currentZoom + step).clamp(
    _controller.minScale,
    _controller.maxScale,
  );

  final visibleRect = _controller.visibleRect;
  final centerInDocument = visibleRect.center;

  await _controller.setZoom(centerInDocument, newZoom);
}
}