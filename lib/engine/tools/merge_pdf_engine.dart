import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/page_selection/page_selection.dart';

class MergePdfInput {
  const MergePdfInput({required this.file, this.selection});

  final File file;
  final PageSelection? selection;
}

class MergePdfEngine {
  const MergePdfEngine();

  Future<File> merge({
    required List<MergePdfInput> inputs,
    required File outputFile,
  }) async {
    final documents = <PdfDocument>[];
    PdfDocument? outputDocument;

    try {
      for (final input in inputs) {
        documents.add(await PdfDocument.openFile(input.file.path));
      }

      outputDocument = await PdfDocument.createNew(sourceName: outputFile.path);

      outputDocument.pages = [
        for (var index = 0; index < inputs.length; index++)
          ..._resolvePages(documents[index], inputs[index].selection),
      ];

      final data = await outputDocument.encodePdf();

      await outputFile.writeAsBytes(data);

      return outputFile;
    } finally {
      for (final document in documents) {
        await document.dispose();
      }

      await outputDocument?.dispose();
    }
  }

  List<PdfPage> _resolvePages(PdfDocument document, PageSelection? selection) {
    if (selection == null) {
      return document.pages;
    }

    final pages = selection.resolve(document.pages.length);

    return [for (final page in pages) document.pages[page - 1]];
  }
}
