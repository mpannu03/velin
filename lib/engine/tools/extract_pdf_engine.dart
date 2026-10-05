import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/page_selection/page_selection.dart';

class ExtractPdfInput {}

class ExtractPdfEngine {
  const ExtractPdfEngine();

  Future<File> extract({
    required File inputFile,
    required PageSelection selection,
    required File outputFile,
  }) async {
    PdfDocument? sourceDocument;
    PdfDocument? outputDocument;

    try {
      sourceDocument = await PdfDocument.openFile(inputFile.path);

      final pages = selection.resolve(sourceDocument.pages.length);

      if (pages.isEmpty) {
        throw ArgumentError('At least one page must be selected.');
      }

      outputDocument = await PdfDocument.createNew(sourceName: outputFile.path);

      outputDocument.pages = [
        for (final page in pages) sourceDocument.pages[page - 1],
      ];

      final data = await outputDocument.encodePdf();

      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(data);

      return outputFile;
    } finally {
      await sourceDocument?.dispose();
      await outputDocument?.dispose();
    }
  }
}
