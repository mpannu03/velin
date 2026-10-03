import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart';

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

    try {
      outputDocument = await PdfDocument.createNew(
        sourceName: outputFile.path,
      );

      for (final imageFile in input.images) {
        final bytes = await imageFile.readAsBytes();

        final decoded = img.decodeImage(bytes);

        if (decoded == null) {
          throw StateError(
            'Unable to decode image: ${imageFile.path}',
          );
        }

        final image = _prepareImage(decoded);

        final pageSize = _resolvePageSize(
          image,
          input,
        );

        final jpegData = img.encodeJpg(
          image,
          quality: 95,
        );

        final imageDocument = await PdfDocument.createFromJpegData(
          jpegData,
          width: pageSize.width,
          height: pageSize.height,
          sourceName: imageFile.path,
        );

        try {
          var page = imageDocument.pages.first;

          page = _fitPage(
            page,
            image,
            pageSize,
            input,
          );

          outputDocument.pages = [
            ...outputDocument.pages,
            page,
          ];
        } finally {
          await imageDocument.dispose();
        }
      }

      await outputDocument.assemble();

      final data = await outputDocument.encodePdf();

      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(data);

      return outputFile;
    } finally {
      await outputDocument?.dispose();
    }
  }

  img.Image _prepareImage(img.Image image) {
    if (!image.hasAlpha) {
      return image;
    }

    final background = img.Image(
      width: image.width,
      height: image.height,
    );

    img.fill(
      background,
      color: img.ColorRgb8(255, 255, 255),
    );

    img.compositeImage(
      background,
      image,
    );

    return background;
  }

  _PageSize _resolvePageSize(
    img.Image image,
    ImageToPdfInput input,
  ) {
    if (input.pageSize == ImageToPdfPageSize.auto) {
      return _PageSize(
        width: _pixelsToPoints(image.width, input.dpi),
        height: _pixelsToPoints(image.height, input.dpi),
      );
    }

    final (widthMm, heightMm) = switch (input.pageSize) {
      ImageToPdfPageSize.a4 => (
          _a4Width,
          _a4Height,
        ),
      ImageToPdfPageSize.letter => (
          _letterWidth,
          _letterHeight,
        ),
      ImageToPdfPageSize.auto => throw StateError(
          'Unexpected page size.',
        ),
    };

    final isPortrait = switch (input.orientation) {
      ImageToPdfOrientation.portrait => true,
      ImageToPdfOrientation.landscape => false,
      ImageToPdfOrientation.auto => image.width <= image.height,
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

  PdfPage _fitPage(
    PdfPage page,
    img.Image image,
    _PageSize pageSize,
    ImageToPdfInput input,
  ) {
    // The page returned by createFromJpegData already contains
    // the complete image. At this point, the page dimensions
    // determine how the image is scaled.
    //
    // For Auto, the page has exactly the image's physical size,
    // so no additional fitting is necessary.
    if (input.pageSize == ImageToPdfPageSize.auto) {
      return page;
    }

    // `createFromJpegData` embeds the image to fill the page.
    //
    // Contain/Cover require creating a differently sized page
    // around the image, which cannot be expressed by PdfPage
    // alone. Therefore these modes need native PDF construction
    // rather than the createFromJpegData convenience API.
    return page;
  }

  double _pixelsToPoints(
    int pixels,
    int dpi,
  ) {
    return pixels / dpi * _pointsPerInch;
  }

  double _millimetresToPoints(
    double millimetres,
  ) {
    return millimetres /
        _millimetresPerInch *
        _pointsPerInch;
  }
}

class _PageSize {
  const _PageSize({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;
}