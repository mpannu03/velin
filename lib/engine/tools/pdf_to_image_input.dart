import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';

enum PdfImageFormat {
  png,
  jpeg,
  webp;

  String get extension => switch (this) {
    png => 'png',
    jpeg => 'jpg',
    webp => 'webp',
  };
}

enum PdfImageColorMode { color, grayscale }

class PdfToImageInput {
  const PdfToImageInput({
    required this.file,
    this.selection,
    this.format = PdfImageFormat.png,
    this.colorMode = PdfImageColorMode.color,
    this.dpi = 150,
    this.quality = 90,
  });

  final File file;
  final PageSelection? selection;
  final PdfImageFormat format;
  final PdfImageColorMode colorMode;
  final int dpi;

  /// Applies to JPEG and WebP. PNG ignores this setting.
  final int quality;
}
