import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';

import 'split_pdf_input.dart';

class SplitPdfEngine {
  const SplitPdfEngine();

  Future<List<File>> split({
    required SplitPdfInput input,
    required Directory outputDirectory,
  }) async {
    PdfDocument? sourceDocument;

    try {
      sourceDocument = await PdfDocument.openFile(input.file.path);

      final pageCount = sourceDocument.pages.length;

      if (pageCount == 0) {
        throw StateError('The PDF contains no pages.');
      }

      final pageGroups = _resolvePageGroups(
        input: input,
        totalPages: pageCount,
      );

      if (pageGroups.isEmpty) {
        throw StateError('No pages selected for splitting.');
      }

      await outputDirectory.create(recursive: true);

      final outputFiles = <File>[];

      for (var index = 0; index < pageGroups.length; index++) {
        final pages = pageGroups[index];

        final outputFile = File(
          '${outputDirectory.path}'
          '${Platform.pathSeparator}'
          '${_buildFileName(input, pages, index)}',
        );

        final outputDocument = await PdfDocument.createNew(
          sourceName: outputFile.path,
        );

        try {
          outputDocument.pages = [
            for (final pageNumber in pages)
              sourceDocument.pages[pageNumber - 1],
          ];

          final data = await outputDocument.encodePdf();

          await outputFile.writeAsBytes(data);

          outputFiles.add(outputFile);
        } finally {
          await outputDocument.dispose();
        }
      }

      return outputFiles;
    } finally {
      await sourceDocument?.dispose();
    }
  }

  List<List<int>> _resolvePageGroups({
    required SplitPdfInput input,
    required int totalPages,
  }) {
    switch (input.mode) {
      case SplitPdfMode.bySelection:
        if (input.selections.isEmpty) {
          throw ArgumentError(
            'At least one page selection is required.',
          );
        }

        return [
          for (final selection in input.selections)
            _resolveSelection(
              selection.resolve(totalPages),
              totalPages,
            ),
        ];

      case SplitPdfMode.byPageCount:
        final count = input.pageCount;

        if (count == null || count <= 0) {
          throw ArgumentError(
            'Page count must be greater than zero.',
          );
        }

        return [
          for (var start = 1; start <= totalPages; start += count)
            [
              for (
                var page = start;
                page < start + count && page <= totalPages;
                page++
              )
                page,
            ],
        ];

      case SplitPdfMode.extractAllPages:
        return [
          for (var page = 1; page <= totalPages; page++)
            [page],
        ];
    }
  }

  List<int> _resolveSelection(
    List<int> pages,
    int totalPages,
  ) {
    if (pages.isEmpty) {
      throw ArgumentError('A page selection cannot be empty.');
    }

    for (final page in pages) {
      if (page < 1 || page > totalPages) {
        throw RangeError(
          'Page $page is outside the valid range 1-$totalPages.',
        );
      }
    }

    return pages;
  }

  String _buildFileName(
    SplitPdfInput input,
    List<int> pages,
    int index,
  ) {
    final fileName = input.file.uri.pathSegments.last;
    final extensionIndex = fileName.lastIndexOf('.');

    final baseName = extensionIndex > 0
        ? fileName.substring(0, extensionIndex)
        : fileName;

    switch (input.mode) {
      case SplitPdfMode.bySelection:
        return '${baseName}_selection_${index + 1}.pdf';

      case SplitPdfMode.byPageCount:
        return '${baseName}_pages_${pages.first}-${pages.last}.pdf';

      case SplitPdfMode.extractAllPages:
        return '${baseName}_page_${pages.first}.pdf';
    }
  }
}