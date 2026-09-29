import 'dart:async';

import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfDocumentEngineController implements DocumentEngineController {
  PdfDocumentEngineController(this._controller);

  final PdfViewerController _controller;

  final StreamController<int?> _currentPageController =
      StreamController<int?>.broadcast();

  @override
  Stream<int?> get currentPageStream => _currentPageController.stream;

  void onPageChanged(int? pageNumber) {
    _currentPageController.add(pageNumber);
  }

  void onViewerReady() {
    _currentPageController.add(_controller.pageNumber);
  }

  @override
  int? get currentPage => _controller.pageNumber;

  @override
  int get pageCount => _controller.pageCount;

  @override
  Future<void> goToPage(int page) async {
    if (page < 1) {
      _controller.setCurrentPageNumber(1);
      return;
    } else if (page > pageCount) { 
      _controller.setCurrentPageNumber(pageCount);
      return;
    }

    _controller.setCurrentPageNumber(page);
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
    final page = currentPage;

    if (page == null || page >= pageCount) {
      return Future.value();
    }

    return goToPage(page + 1);
  }

  @override
  Future<void> previousPage() {
    final page = currentPage;

    if (page == null || page <= 1) {
      return Future.value();
    }

    return goToPage(page - 1);
  }

  @override
  Future<void> dispose() async {
    await _currentPageController.close();
  }
}