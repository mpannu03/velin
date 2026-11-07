import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

import 'add_watermark_input.dart';

class AddWatermarkEngine {
  AddWatermarkEngine({required this._pdf});

  final Pdf _pdf;

  Future<File> addWatermark({required AddWatermarkInput input}) async {
    _validate(input);

    return writeAtomically(input.outputFile, (temporary) async {
      final source = FileSource(input.file);
      final output = await FileSink.create(temporary);

      PdfEditor? editor;

      try {
        editor = await _pdf.edit(source);

        final pageCount = await editor.pageCount;
        final pages = _resolvePages(input.selection, pageCount);

        switch (input.type) {
          case WatermarkType.text:
            await _addTextWatermark(editor, input, pages);

          case WatermarkType.image:
            await _addImageWatermark(editor, input, pages);
        }

        await editor.save(output);
      } finally {
        await editor?.dispose();
        await output.close();
      }
    });
  }

  Future<void> _addTextWatermark(
    PdfEditor editor,
    AddWatermarkInput input,
    List<int> pages,
  ) async {
    final style = PdfWatermarkStyle(
      fontSize: input.fontSize,
      fontName: input.fontName,
      opacity: input.opacity,
      rotation: input.rotation,
      color: _parseColor(input.colorHex),
    );

    for (final page in pages) {
      final position = await _textPosition(editor, page, input);

      await editor.addWatermark(
        page,
        input.text,
        style: style,
        position: position,
        layer: _resolveLayer(input.layer),
      );
    }
  }

  Future<void> _addImageWatermark(
    PdfEditor editor,
    AddWatermarkInput input,
    List<int> pages,
  ) async {
    final imagePath = input.imageFile!.path;
    final rotation = input.rotation;

    // Decoding, rotating and re-encoding a large image takes long enough to
    // freeze the window, so it runs on a background isolate.
    final prepared = await runInBackground(_prepareWatermarkImage, (
      imagePath,
      rotation,
    ));

    if (prepared == null) {
      throw InvalidImageFailure(path: imagePath);
    }

    final imageSource = MemorySource(prepared.pngBytes);

    for (final page in pages) {
      final mediaBox = await editor.pageMediaBox(page);

      final pageWidth = mediaBox.width;
      final pageHeight = mediaBox.height;

      final width = pageWidth * (input.imageWidthPercent / 100);

      final aspectRatio = prepared.height / prepared.width;

      final height = width * aspectRatio;

      final rect = _resolveImageRect(
        position: input.position,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
        width: width,
        height: height,
        xOffset: input.xOffset,
        yOffset: input.yOffset,
      );

      await editor.addImageStamp(
        page,
        imageSource,
        rect: rect,
        opacity: input.opacity,
      );
    }
  }

  Future<PdfWatermarkPosition> _textPosition(
    PdfEditor editor,
    int page,
    AddWatermarkInput input,
  ) async {
    if (input.xOffset == 0 && input.yOffset == 0) {
      return _resolveNamedPosition(input.position);
    }

    final mediaBox = await editor.pageMediaBox(page);

    final width = _estimateTextWidth(input.text, input.fontSize);

    final height = input.fontSize * 1.4;

    final rect = _resolveImageRect(
      position: input.position,
      pageWidth: mediaBox.width,
      pageHeight: mediaBox.height,
      width: width,
      height: height,
      xOffset: input.xOffset,
      yOffset: input.yOffset,
    );

    return PdfWatermarkPosition.exact(
      x: rect.x,
      y: rect.y,
      width: rect.width,
      height: rect.height,
    );
  }

  PdfWatermarkPosition _resolveNamedPosition(WatermarkPosition position) {
    return switch (position) {
      WatermarkPosition.center => const PdfWatermarkPosition.center(),

      WatermarkPosition.topLeft => const PdfWatermarkPosition.corner(
        PdfCorner.topLeft,
      ),

      WatermarkPosition.topRight => const PdfWatermarkPosition.corner(
        PdfCorner.topRight,
      ),

      WatermarkPosition.bottomLeft => const PdfWatermarkPosition.corner(
        PdfCorner.bottomLeft,
      ),

      WatermarkPosition.bottomRight => const PdfWatermarkPosition.corner(
        PdfCorner.bottomRight,
      ),
    };
  }

  PdfRect _resolveImageRect({
    required WatermarkPosition position,
    required double pageWidth,
    required double pageHeight,
    required double width,
    required double height,
    required double xOffset,
    required double yOffset,
  }) {
    double x;
    double y;

    switch (position) {
      case WatermarkPosition.center:
        x = (pageWidth - width) / 2;
        y = (pageHeight - height) / 2;

      case WatermarkPosition.topLeft:
        x = 0;
        y = pageHeight - height;

      case WatermarkPosition.topRight:
        x = pageWidth - width;
        y = pageHeight - height;

      case WatermarkPosition.bottomLeft:
        x = 0;
        y = 0;

      case WatermarkPosition.bottomRight:
        x = pageWidth - width;
        y = 0;
    }

    return PdfRect(
      x: x + xOffset,
      y: y + yOffset,
      width: width,
      height: height,
    );
  }

  double _estimateTextWidth(String text, double fontSize) {
    // A conservative approximation for the standard
    // sans-serif watermark font.
    return math.max(fontSize * 2, text.length * fontSize * 0.58);
  }

  List<int> _resolvePages(PageSelection? selection, int pageCount) {
    if (selection == null) {
      return [for (var page = 0; page < pageCount; page++) page];
    }

    return [for (final page in selection.resolve(pageCount)) page - 1];
  }

  PdfWatermarkLayer _resolveLayer(WatermarkLayer layer) {
    return switch (layer) {
      WatermarkLayer.foreground => PdfWatermarkLayer.foreground,

      WatermarkLayer.background => PdfWatermarkLayer.background,
    };
  }

  PdfColor _parseColor(String value) {
    final hex = value.replaceFirst('#', '').trim();

    if (hex.length != 6) {
      throw ArgumentError.value(
        value,
        'colorHex',
        'Expected a six-digit hexadecimal color.',
      );
    }

    final rgb = int.tryParse(hex, radix: 16);

    if (rgb == null) {
      throw ArgumentError.value(
        value,
        'colorHex',
        'Expected a valid hexadecimal color.',
      );
    }

    return PdfColor(
      ((rgb >> 16) & 0xff).toDouble(),
      ((rgb >> 8) & 0xff).toDouble(),
      (rgb & 0xff).toDouble(),
    );
  }

  void _validate(AddWatermarkInput input) {
    if (!input.file.existsSync()) {
      throw ArgumentError.value(
        input.file,
        'file',
        'The input PDF does not exist.',
      );
    }

    ensureOutputDiffersFromInputs(input.outputFile, [input.file]);

    if (input.type == WatermarkType.text && input.text.trim().isEmpty) {
      throw ArgumentError.value(
        input.text,
        'text',
        'Watermark text cannot be empty.',
      );
    }

    if (input.type == WatermarkType.image && input.imageFile == null) {
      throw ArgumentError('An image file is required for an image watermark.');
    }

    if (input.type == WatermarkType.image && !input.imageFile!.existsSync()) {
      throw ArgumentError.value(
        input.imageFile,
        'imageFile',
        'The watermark image does not exist.',
      );
    }

    if (input.opacity < 0.05 || input.opacity > 1) {
      throw ArgumentError.value(
        input.opacity,
        'opacity',
        'Opacity must be between 0.05 and 1.0.',
      );
    }

    if (input.fontSize <= 0) {
      throw ArgumentError.value(
        input.fontSize,
        'fontSize',
        'Font size must be greater than zero.',
      );
    }

    if (input.imageWidthPercent <= 0 || input.imageWidthPercent > 100) {
      throw ArgumentError.value(
        input.imageWidthPercent,
        'imageWidthPercent',
        'Image width must be between 0 and 100.',
      );
    }
  }
}

/// A watermark image ready to stamp: rotated and re-encoded as PNG.
class _PreparedImage {
  const _PreparedImage(this.pngBytes, this.width, this.height);

  final Uint8List pngBytes;
  final int width;
  final int height;
}

/// Runs on a background isolate: top-level so it captures nothing.
///
/// Returns `null` when the file is not a decodable image.
_PreparedImage? _prepareWatermarkImage((String, double) job) {
  final (path, rotation) = job;

  final decoded = img.decodeImage(File(path).readAsBytesSync());

  if (decoded == null) return null;

  final normalized = rotation % 360;
  final rotated = normalized == 0
      ? decoded
      : img.copyRotate(decoded, angle: normalized);

  return _PreparedImage(
    Uint8List.fromList(img.encodePng(rotated)),
    rotated.width,
    rotated.height,
  );
}
