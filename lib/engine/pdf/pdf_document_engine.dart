import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';

import 'pdf_document_engine_controller.dart';

class PdfDocumentEngine implements DocumentEngine {
  PdfDocumentEngine({
    required this.document,
    PdfViewerController? controller,
  }) : _controller = controller ?? PdfViewerController();

  @override
  final Document document;

  final PdfViewerController _controller;

  @override
  DocumentEngineCapabilities get capabilities =>
      const DocumentEngineCapabilities(
        textSelection: true,
        search: true,
      );

  @override
  DocumentEngineController get controller => PdfDocumentEngineController(
        _controller,
      );

  @override
  Widget buildViewer() {
    return PdfViewer.file(
      document.path,
      controller: _controller,
    );
  }
}
