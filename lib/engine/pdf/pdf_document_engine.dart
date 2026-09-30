import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/pdf/pdf_text_search_capability.dart';

import 'pdf_document_engine_actions.dart';

class PdfDocumentEngine implements DocumentEngine {
  PdfDocumentEngine({
    required this.document,
    PdfViewerController? controller,
  }) : _controller = controller ?? PdfViewerController() {
    _actions = PdfDocumentEngineActions(_controller);
    _controller.addListener(_onControllerChanged);
  }

  @override
  final Document document;

  final PdfViewerController _controller;

  late final PdfDocumentEngineActions _actions;

  late final PdfTextSearchCapability _textSearch =
      PdfTextSearchCapability(_controller);

  DocumentEngineListener? _listener;

  double? _lastZoom;

  @override
  DocumentEngineCapabilities get capabilities =>
      const DocumentEngineCapabilities(
        textSelection: true,
        search: true,
      );

  @override
  DocumentEngineSnapshot get snapshot {
    return DocumentEngineSnapshot(
      currentPage: _controller.pageNumber,
      pageCount: _controller.pageCount,
      zoom: _controller.currentZoom,
    );
  }

  @override
  TextSearchCapability? get textSearch => _textSearch;

  @override
  DocumentEngineActions get actions => _actions;

  @override
  DocumentEngineListener? get listener => _listener;

  @override
  set listener(DocumentEngineListener? listener) {
    _listener = listener;
  }

  @override
  Widget buildViewer({
    required DocumentEngineConfig config,
  }) {
    return PdfViewer.file(
      document.path,
      controller: _controller,
      params: PdfViewerParams(
        backgroundColor: config.backgroundColor ?? Colors.grey,
        onPageChanged: _onPageChanged,
        onViewerReady: (_, _) => _onViewerReady(),
      ),
    );
  }

  void _onControllerChanged() {
    final zoom = _controller.currentZoom;

    if (_lastZoom == zoom) {
      return;
    }

    _lastZoom = zoom;
    _listener?.onZoomChanged(zoom);
  }

  void _onPageChanged(int? pageNumber) {
    _listener?.onPageChanged(pageNumber);
  }

  void _onViewerReady() {
    _lastZoom = _controller.currentZoom;

    _listener?.onReady();
    _listener?.onPageChanged(_controller.pageNumber);
    _listener?.onZoomChanged(_controller.currentZoom);
  }
}