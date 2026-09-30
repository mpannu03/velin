import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfDocumentEngineActions implements DocumentEngineActions {
  PdfDocumentEngineActions(this._controller);

  final PdfViewerController _controller;

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
  Future<void> zoomIn() {
    return _controller.zoomUp();
  }

  @override
  Future<void> zoomOut() {
    return _controller.zoomDown();
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
}