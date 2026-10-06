import 'dart:io';
import 'dart:typed_data';

import 'package:pdfrx_engine/pdfrx_engine.dart';

class PdfPageRenderer {
  Future<File> render({
    required File document,
    required int page,
    required File output,
    required int width,
  }) async {
    final pdf = await PdfDocument.openFile(document.path);

    try {
      final pdfPage = pdf.pages[page - 1];

      final scale = width / pdfPage.width;
      final height = (pdfPage.height * scale).round();

      final image = await pdfPage.render(width: width, height: height);

      if (image == null) {
        throw StateError('Failed to render page $page of ${document.path}.');
      }

      final bytes = image.pixels;

      await output.writeAsBytes(
        _encodePng(width: image.width, height: image.height, pixels: bytes),
      );

      return output;
    } finally {
      await pdf.dispose();
    }
  }

  Uint8List _encodePng({
    required int width,
    required int height,
    required Uint8List pixels,
  }) {
    // We'll use the existing image package here.
    throw UnimplementedError();
  }
}
