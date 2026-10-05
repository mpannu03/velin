import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/page_selection/page_selection.dart';

class RotatePdfEngine {
  const RotatePdfEngine();

  Future<File> rotate({
    required File inputFile,
    required File outputFile,
    required int degrees,
    PageSelection? selection,
  }) async {
    final rotation = switch (degrees) {
      90 => PdfPageRotation.clockwise90,
      180 => PdfPageRotation.clockwise180,
      270 => PdfPageRotation.clockwise270,
      _ => throw ArgumentError.value(
        degrees,
        'degrees',
        'Must be 90, 180, or 270.',
      ),
    };

    PdfDocument? sourceDocument;
    PdfDocument? outputDocument;

    try {
      sourceDocument = await PdfDocument.openFile(inputFile.path);

      final totalPages = sourceDocument.pages.length;

      final selectedPages = selection?.resolve(totalPages).toSet();

      if (selectedPages != null) {
        for (final page in selectedPages) {
          if (page < 1 || page > totalPages) {
            throw RangeError(
              'Page $page is outside the valid range 1-$totalPages.',
            );
          }
        }
      }

      outputDocument = await PdfDocument.createNew(sourceName: outputFile.path);

      outputDocument.pages = [
        for (var index = 0; index < totalPages; index++)
          if (selectedPages == null || selectedPages.contains(index + 1))
            sourceDocument.pages[index].rotatedBy(rotation)
          else
            sourceDocument.pages[index],
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
