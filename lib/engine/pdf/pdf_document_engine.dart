import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';

import 'pdf_document_engine_controller.dart';

class PdfDocumentEngine implements DocumentEngine {
  PdfDocumentEngine({
    required this.document,
    PdfViewerController? controller,
  }) : _controller = controller ?? PdfViewerController() {
    _engineController = PdfDocumentEngineController(_controller);
  }

  @override
  final Document document;

  final PdfViewerController _controller;

  late final PdfDocumentEngineController _engineController;

  @override
  DocumentEngineCapabilities get capabilities =>
      const DocumentEngineCapabilities(
        textSelection: true,
        search: true,
      );

  @override
  DocumentEngineController get controller => _engineController;

  @override
  Widget buildViewer({
    required Color backgroundColor,
  }) {
    return PdfViewer.file(
      document.path,
      controller: _controller,
      params: PdfViewerParams(
        backgroundColor: backgroundColor,
        onPageChanged: _engineController.onPageChanged,
        onViewerReady: (_, __) => _engineController.onViewerReady(),
      ),
    );
  }

  @override
  Future<void> dispose() {
    return _engineController.dispose();
  }
}
