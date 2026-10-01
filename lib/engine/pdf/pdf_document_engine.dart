import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';

import 'pdf.dart';

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

  PdfTextSearchCapability? _textSearch;

  PdfBookmarkCapability? _bookmark;

  PdfAnnotationCapability? _annotation;

  DocumentEngineListener? _listener;

  double? _lastZoom;

  /// Keep annotations boiler as pdfrx implementation is not fully
  /// implemented comments is marked false.
  @override
  DocumentEngineCapabilities get capabilities =>
      const DocumentEngineCapabilities(
        textSelection: true,
        search: true,
        bookmarks: true,
        comments: false,
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
  BookmarkCapability? get bookmark => _bookmark;

  @override
  AnnotationCapability? get annotation => _annotation;

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
        pagePaintCallbacks: [
           (canvas, pageRect, page) {
            _textSearch?.pageTextMatchPaintCallback(canvas, pageRect, page);
          },
        ]
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
    _textSearch ??= PdfTextSearchCapability(_controller);

    _bookmark ??= PdfBookmarkCapability(_controller);

    _annotation ??= PdfAnnotationCapability(_controller);

    _lastZoom = _controller.currentZoom;

    _listener?.onReady();
    _listener?.onPageChanged(_controller.pageNumber);
    _listener?.onZoomChanged(_controller.currentZoom);
  }
}