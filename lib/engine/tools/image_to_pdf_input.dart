import 'dart:io';

enum ImageToPdfPageSize {
  auto,
  a4,
  letter,
}

enum ImageToPdfOrientation {
  auto,
  portrait,
  landscape,
}

enum ImageToPdfFit {
  contain,
  cover,
  stretch,
}

class ImageToPdfInput {
  const ImageToPdfInput({
    required this.images,
    this.pageSize = ImageToPdfPageSize.auto,
    this.orientation = ImageToPdfOrientation.auto,
    this.fit = ImageToPdfFit.contain,
    this.margin = 10,
    this.dpi = 150,
  });

  final List<File> images;
  final ImageToPdfPageSize pageSize;
  final ImageToPdfOrientation orientation;
  final ImageToPdfFit fit;

  /// Margin in millimetres.
  final double margin;

  /// Used only when [pageSize] is [ImageToPdfPageSize.auto].
  final int dpi;
}