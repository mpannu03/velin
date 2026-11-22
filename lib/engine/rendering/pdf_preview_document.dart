import 'dart:async';
import 'dart:ui' as ui;

import 'package:pdfrx_engine/pdfrx_engine.dart';

/// An open document that renders small page images for on-screen previews,
/// e.g. the page grid next to a tool form.
///
/// Renders run one at a time, in the order they were asked for, so a long
/// grid never floods pdfium. Call [dispose] when the preview goes away;
/// renders still queued then resolve to null.
class PdfPreviewDocument {
  PdfPreviewDocument._(this._document);

  static Future<PdfPreviewDocument> open(String path) async {
    return PdfPreviewDocument._(await PdfDocument.openFile(path));
  }

  final PdfDocument _document;
  Future<void> _queue = Future.value();
  bool _disposed = false;

  int get pageCount => _document.pages.length;

  /// Width / height of [page] (1-based), as shown on screen.
  double aspectRatio(int page) {
    final pdfPage = _document.pages[page - 1];
    return pdfPage.width / pdfPage.height;
  }

  /// Renders [page] (1-based) [width] pixels wide, or null if the preview
  /// was disposed first or pdfium could not render it.
  Future<ui.Image?> renderPage(int page, {required int width}) {
    final result = _queue.then((_) => _render(page, width));
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<ui.Image?> _render(int page, int width) async {
    if (_disposed) return null;

    final pdfPage = _document.pages[page - 1];
    final height = (pdfPage.height * width / pdfPage.width).round();
    final rendered = await pdfPage.render(
      fullWidth: width.toDouble(),
      fullHeight: height.toDouble(),
    );
    if (rendered == null) return null;

    final ui.ImmutableBuffer buffer;
    try {
      // Copies the pixels out of pdfium's native buffer.
      buffer = await ui.ImmutableBuffer.fromUint8List(rendered.pixels);
    } finally {
      rendered.dispose();
    }

    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: rendered.width,
      height: rendered.height,
      pixelFormat: ui.PixelFormat.bgra8888,
    );
    try {
      final codec = await descriptor.instantiateCodec();
      try {
        final frame = await codec.getNextFrame();
        if (_disposed) {
          frame.image.dispose();
          return null;
        }
        return frame.image;
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
      buffer.dispose();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    // Let the render in flight finish before closing the document.
    await _queue;
    await _document.dispose();
  }
}
