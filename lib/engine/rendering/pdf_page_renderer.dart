import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:velin/core/result/result.dart';

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

        try {
          final bytes = _encodePng(
            width: image.width,
            height: image.height,
            pixels: image.pixels,
          );

          await output.writeAsBytes(bytes);
          return output;
        } finally {
          image.dispose();
        }
      } finally {
        await pdf.dispose();
      }
    });
  }

  Uint8List _encodePng({
    required int width,
    required int height,
    required Uint8List pixels,
  }) {
    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: pixels.buffer,
      numChannels: 4,
      order: img.ChannelOrder.bgra,
    );

    return Uint8List.fromList(img.encodePng(image));
  }
}
