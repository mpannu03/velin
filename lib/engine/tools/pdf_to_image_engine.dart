import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/page_selection/page_selection_error.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

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
          throw InvalidPageSelectionFailure(
            PageSelectionOutOfBoundsError(page: page, totalPages: totalPages),
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

        final Uint8List bytes;

        try {
          final job = _EncodeJob(
            pixels: rendered.pixels,
            width: rendered.width,
            height: rendered.height,
            format: input.format,
            quality: input.quality,
            grayscale: input.colorMode == PdfImageColorMode.grayscale,
          );

          // Encoding a 300–600 DPI page takes seconds; on the UI isolate it
          // would freeze the window. Rendering stays here because pdfium
          // handles cannot leave this isolate.
          bytes = await runInBackground(_encodePage, job);
        } finally {
          rendered.dispose();
        }

        final outputFile = File(
          p.join(
            outputDirectory.path,
            '${baseName}_page_$pageNumber.${input.format.extension}',
          ),
        );

        outputFiles.add(await writeBytesAtomically(outputFile, bytes));
      }

      return outputFiles;
    } finally {
      await document?.dispose();
    }
  }

  String _baseName(File file) {
    final name = file.uri.pathSegments.last;
    final extensionIndex = name.lastIndexOf('.');

    return extensionIndex > 0 ? name.substring(0, extensionIndex) : name;
  }
}

class _EncodeJob {
  const _EncodeJob({
    required this.pixels,
    required this.width,
    required this.height,
    required this.format,
    required this.quality,
    required this.grayscale,
  });

  /// BGRA pixels as produced by pdfium.
  final Uint8List pixels;
  final int width;
  final int height;
  final PdfImageFormat format;
  final int quality;
  final bool grayscale;
}

/// Runs on a background isolate: top-level so it captures nothing.
Uint8List _encodePage(_EncodeJob job) {
  var image = img.Image.fromBytes(
    width: job.width,
    height: job.height,
    bytes: job.pixels.buffer,
    bytesOffset: job.pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.bgra,
  );

  if (job.grayscale) {
    image = img.grayscale(image);
  }

  return switch (job.format) {
    PdfImageFormat.png => img.encodePng(image),
    PdfImageFormat.jpeg => img.encodeJpg(image, quality: job.quality),
    PdfImageFormat.webp => img.encodeWebP(
      image,
      lossless: false,
      quality: job.quality,
    ),
  };
}
