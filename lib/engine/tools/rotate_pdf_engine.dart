import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task_context.dart';

class RotatePdfEngine {
  const RotatePdfEngine();

  Future<File> rotate({
    required File inputFile,
    required File outputFile,
    required int degrees,
    PageSelection? selection,
    TaskContext? context,
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

    ensureOutputDiffersFromInputs(outputFile, [inputFile]);

    PdfDocument? sourceDocument;
    PdfDocument? outputDocument;

    try {
      sourceDocument = await PdfDocument.openFile(inputFile.path);

      final totalPages = sourceDocument.pages.length;

      final selectedPages = selection?.resolve(totalPages).toSet();

      if (selectedPages != null) {
        for (final page in selectedPages) {
          if (page < 1 || page > totalPages) {
            throw InvalidPageSelectionFailure(
              PageSelectionOutOfBoundsError(page: page, totalPages: totalPages),
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

      context?.throwIfCancelled();

      return await writeBytesAtomically(outputFile, data);
    } finally {
      await sourceDocument?.dispose();
      await outputDocument?.dispose();
    }
  }
}
