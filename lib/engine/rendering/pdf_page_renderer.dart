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
  }) async {
    try {
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
          return Failure(
            StateError('Failed to render page $page of ${document.path}.'),
          );
        }

        final bytes = _encodePng(
          width: image.width,
          height: image.height,
          pixels: image.pixels,
        );

        await output.writeAsBytes(bytes);
        return Success(output);
      } finally {
        await pdf.dispose();
      }
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
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
      order: img.ChannelOrder.rgba,
    );

    return Uint8List.fromList(img.encodePng(image));
  }
}
