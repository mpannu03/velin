import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';

import 'pdf/pdf_document_engine.dart';

class DocumentEngineFactory {
  const DocumentEngineFactory();

  DocumentEngine create(Document document) {
    final extension = document.path.split('.').last.toLowerCase();

    return switch (extension) {
      'pdf' => PdfDocumentEngine(document: document),
      _ => throw UnsupportedError('Unsupported document type: .$extension'),
    };
  }
}
