import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfDocumentEngineController implements DocumentEngineController {
  const PdfDocumentEngineController(this._controller);

  final PdfViewerController _controller;

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
  Future<void> nextPage() async {
    final pageNumber = _controller.pageNumber;

    if (pageNumber == null || pageNumber >= _controller.pageCount) {
      return;
    }

    _controller.setCurrentPageNumber(pageNumber + 1);
  }

  @override
  Future<void> previousPage() async {
    final pageNumber = _controller.pageNumber;

    if (pageNumber == null || pageNumber <= 1) {
      return;
    }

    _controller.setCurrentPageNumber(pageNumber - 1);
  }
}