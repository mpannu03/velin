import 'dart:async';

import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfDocumentEngineController implements DocumentEngineController {
  PdfDocumentEngineController(this._controller) {
    _controller.addListener(_onControllerChanged);
  }

  final PdfViewerController _controller;

  final StreamController<int?> _currentPageController =
      StreamController<int?>.broadcast();

  final StreamController<double> _zoomController =
      StreamController<double>.broadcast();

  double? _lastZoom;

  @override
  Stream<int?> get currentPageStream => _currentPageController.stream;

  @override
  Stream<double> get zoomStream => _zoomController.stream;

  @override
  int? get currentPage => _controller.pageNumber;

  @override
  int get pageCount => _controller.pageCount;

  @override
  double get zoom => _controller.currentZoom;

  void _onControllerChanged() {
    _emitZoom();
  }

  void _emitZoom() {
    final zoom = _controller.currentZoom;

    if (_lastZoom == zoom) {
      return;
    }

    _lastZoom = zoom;
    _zoomController.add(zoom);
  }

  void onPageChanged(int? pageNumber) {
    _currentPageController.add(pageNumber);
  }

  void onViewerReady() {
    _currentPageController.add(_controller.pageNumber);
    _emitZoom();
  }

  @override
  Future<void> goToPage(int page) async {
    if (page < 1 || page > pageCount) {
      return;
    }

    final matrix = _controller.calcMatrixForPage(
      pageNumber: page,
    );

    await _controller.goTo(matrix);
    _emitZoom();
  }

  @override
  Future<void> zoomIn() async {
    await _controller.zoomUp();
    _emitZoom();
  }

  @override
  Future<void> zoomOut() async {
    await _controller.zoomDown();
    _emitZoom();
  }

  @override
  Future<void> fitWidth() async {
    final pageNumber = _controller.pageNumber ?? 1;

    final matrix = _controller.calcMatrixFitWidthForPage(
      pageNumber: pageNumber,
    );

    if (matrix != null) {
      await _controller.goTo(matrix);
      _emitZoom();
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
      _emitZoom();
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
    _controller.removeListener(_onControllerChanged);

    await _currentPageController.close();
    await _zoomController.close();
  }
}