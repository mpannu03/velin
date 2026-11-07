import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

class PdfPageRenderer {
  Future<Result<File>> render({
    required File document,
    required int page,
    required File output,
    required int width,
  }) {
    return Result.guard(() async {
      final pdf = await PdfDocument.openFile(document.path);
      try {
        final pdfPage = pdf.pages[page - 1];

        final scale = width / pdfPage.width;
        final outHeight = (pdfPage.height * scale).round();

        final image = await pdfPage.render(
          fullWidth: width.toDouble(),
          fullHeight: outHeight.toDouble(),
        );

        if (image == null) {
          throw StateError('Failed to render page $page of ${document.path}.');
        }

        final Uint8List bytes;

        try {
          final pixels = image.pixels;
          final imageWidth = image.width;
          final imageHeight = image.height;

          // PNG encoding is pure Dart; keep it off the UI isolate so opening
          // a document never stutters while its thumbnail is generated.
          bytes = await runInBackground(_encodeBgraAsPng, (
            pixels,
            imageWidth,
            imageHeight,
          ));
        } finally {
          image.dispose();
        }

        await output.writeAsBytes(bytes);
        return output;
      } finally {
        await pdf.dispose();
      }
    });
  }
}

/// Runs on a background isolate: top-level so it captures nothing.
Uint8List _encodeBgraAsPng((Uint8List, int, int) job) {
  final (pixels, width, height) = job;

  final image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: pixels.buffer,
    bytesOffset: pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.bgra,
  );

  return img.encodePng(image);
}
