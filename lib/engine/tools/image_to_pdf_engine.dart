import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

import 'image_to_pdf_input.dart';

class ImageToPdfEngine {
  const ImageToPdfEngine();

  static const _pointsPerInch = 72.0;
  static const _millimetresPerInch = 25.4;

  static const _a4Width = 210.0;
  static const _a4Height = 297.0;

  static const _letterWidth = 215.9;
  static const _letterHeight = 279.4;

  Future<File> convert({
    required ImageToPdfInput input,
    required File outputFile,
  }) async {
    if (input.images.isEmpty) {
      throw ArgumentError('At least one image is required.');
    }

    if (input.margin < 0) {
      throw ArgumentError.value(
        input.margin,
        'margin',
        'Margin cannot be negative.',
      );
    }

    if (input.dpi <= 0) {
      throw ArgumentError.value(
        input.dpi,
        'dpi',
        'DPI must be greater than zero.',
      );
    }

    PdfDocument? outputDocument;

    final sourceDocuments = <PdfDocument>[];

    try {
      outputDocument = await PdfDocument.createNew(sourceName: outputFile.path);

      final pages = <PdfPage>[];

      for (final imageFile in input.images) {
        final path = imageFile.path;

        // Decoding and re-encoding a photo takes long enough to freeze the
        // window, so it runs on a background isolate. One image at a time
        // keeps peak memory to a single decoded image.
        final jpeg = await runInBackground(_decodeToJpeg, path);

        if (jpeg == null) {
          throw InvalidImageFailure(path: path);
        }

        final pageSize = _resolvePageSize(jpeg.width, jpeg.height, input);

        final imageDocument = await PdfDocument.createFromJpegData(
          jpeg.bytes,
          width: pageSize.width,
          height: pageSize.height,
          sourceName: imageFile.path,
        );

        sourceDocuments.add(imageDocument);

        pages.add(imageDocument.pages.first);
      }

      outputDocument.pages = pages;

      final data = await outputDocument.encodePdf();

      return await writeBytesAtomically(outputFile, data);
    } finally {
      for (final document in sourceDocuments) {
        await document.dispose();
      }

      await outputDocument?.dispose();
    }
  }

  _PageSize _resolvePageSize(
    int imageWidth,
    int imageHeight,
    ImageToPdfInput input,
  ) {
    if (input.pageSize == ImageToPdfPageSize.auto) {
      return _PageSize(
        width: _pixelsToPoints(imageWidth, input.dpi),
        height: _pixelsToPoints(imageHeight, input.dpi),
      );
    }

    final (widthMm, heightMm) = switch (input.pageSize) {
      ImageToPdfPageSize.a4 => (_a4Width, _a4Height),
      ImageToPdfPageSize.letter => (_letterWidth, _letterHeight),
      ImageToPdfPageSize.auto => throw StateError('Unexpected page size.'),
    };

    final isPortrait = switch (input.orientation) {
      ImageToPdfOrientation.portrait => true,
      ImageToPdfOrientation.landscape => false,
      ImageToPdfOrientation.auto => imageWidth <= imageHeight,
    };

    return isPortrait
        ? _PageSize(
            width: _millimetresToPoints(widthMm),
            height: _millimetresToPoints(heightMm),
          )
        : _PageSize(
            width: _millimetresToPoints(heightMm),
            height: _millimetresToPoints(widthMm),
          );
  }

  double _pixelsToPoints(int pixels, int dpi) {
    return pixels / dpi * _pointsPerInch;
  }

  double _millimetresToPoints(double millimetres) {
    return millimetres / _millimetresPerInch * _pointsPerInch;
  }
}

class _PageSize {
  const _PageSize({required this.width, required this.height});

  final double width;
  final double height;
}

class _Jpeg {
  const _Jpeg(this.bytes, this.width, this.height);

  final Uint8List bytes;
  final int width;
  final int height;
}

/// Runs on a background isolate: top-level so it captures nothing.
///
/// Decodes any supported image, flattens transparency onto white (JPEG has
/// no alpha) and re-encodes it as JPEG. Returns `null` when the file is not
/// a decodable image.
_Jpeg? _decodeToJpeg(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());

  if (decoded == null) return null;

  var image = decoded;

  if (image.hasAlpha) {
    final background = img.Image(width: image.width, height: image.height);
    img.fill(background, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(background, image);
    image = background;
  }

  return _Jpeg(img.encodeJpg(image, quality: 95), image.width, image.height);
}
