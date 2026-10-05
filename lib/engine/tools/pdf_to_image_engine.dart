import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart';

import 'pdf_to_image_input.dart';

class PdfToImageEngine {
  const PdfToImageEngine();

  static const _supportedDpi = {72, 150, 300, 600};

  Future<List<File>> convert({
    required PdfToImageInput input,
    required Directory outputDirectory,
  }) async {
    if (!_supportedDpi.contains(input.dpi)) {
      throw ArgumentError.value(
        input.dpi,
        'dpi',
        'Supported resolutions are 72, 150, 300, and 600 DPI.',
      );
    }

    if (input.quality < 1 || input.quality > 100) {
      throw ArgumentError.value(
        input.quality,
        'quality',
        'Quality must be between 1 and 100.',
      );
    }

    PdfDocument? document;

    try {
      document = await PdfDocument.openFile(input.file.path);

      final totalPages = document.pages.length;

      final selectedPages = input.selection == null
          ? List<int>.generate(totalPages, (index) => index + 1)
          : input.selection!.resolve(totalPages).toSet().toList();

      if (selectedPages.isEmpty) {
        throw ArgumentError('At least one page must be selected.');
      }

      for (final page in selectedPages) {
        if (page < 1 || page > totalPages) {
          throw RangeError(
            'Page $page is outside the valid range 1-$totalPages.',
          );
        }
      }

      await outputDirectory.create(recursive: true);

      final outputFiles = <File>[];
      final baseName = _baseName(input.file);

      for (final pageNumber in selectedPages) {
        final page = document.pages[pageNumber - 1];

        // PDF dimensions are measured in points (72 points per inch).
        final width = (page.width * input.dpi / 72).round();
        final height = (page.height * input.dpi / 72).round();

        final rendered = await page.render(
          width: width,
          height: height,
          fullWidth: width.toDouble(),
          fullHeight: height.toDouble(),
          backgroundColor: 0xFFFFFFFF,
        );

        if (rendered == null) {
          throw StateError('Failed to render page $pageNumber.');
        }

        try {
          var image = rendered.createImageNF();

          if (input.colorMode == PdfImageColorMode.grayscale) {
            image = img.grayscale(image);
          }

          final bytes = _encodeImage(image, input);

          final outputFile = File(
            '${outputDirectory.path}'
            '${Platform.pathSeparator}'
            '${baseName}_page_$pageNumber.'
            '${input.format.extension}',
          );

          await outputFile.writeAsBytes(bytes);
          outputFiles.add(outputFile);
        } finally {
          rendered.dispose();
        }
      }

      return outputFiles;
    } finally {
      await document?.dispose();
    }
  }

  List<int> _encodeImage(img.Image image, PdfToImageInput input) {
    return switch (input.format) {
      PdfImageFormat.png => img.encodePng(image),
      PdfImageFormat.jpeg => img.encodeJpg(image, quality: input.quality),
      PdfImageFormat.webp => img.encodeWebP(
        image,
        lossless: false,
        quality: input.quality,
      ),
    };
  }

  String _baseName(File file) {
    final name = file.uri.pathSegments.last;
    final extensionIndex = name.lastIndexOf('.');

    return extensionIndex > 0 ? name.substring(0, extensionIndex) : name;
  }
}
