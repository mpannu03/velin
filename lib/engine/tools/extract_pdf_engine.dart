import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task_context.dart';

class ExtractPdfInput {}

class ExtractPdfEngine {
  const ExtractPdfEngine();

  Future<File> extract({
    required File inputFile,
    required PageSelection selection,
    required File outputFile,
    TaskContext? context,
  }) async {
    ensureOutputDiffersFromInputs(outputFile, [inputFile]);

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

      context?.throwIfCancelled();

      return await writeBytesAtomically(outputFile, data);
    } finally {
      await sourceDocument?.dispose();
      await outputDocument?.dispose();
    }
  }
}
