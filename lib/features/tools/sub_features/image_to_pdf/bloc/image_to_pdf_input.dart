import 'dart:io';

import 'package:velin/engine/engine.dart';

/// User-facing model for a single image added to the Image to PDF tool.
class ImageToPdfToolInput {
  const ImageToPdfToolInput({required this.filePath});

  final String filePath;

  ImageToPdfToolInput copyWith({String? filePath}) {
    return ImageToPdfToolInput(filePath: filePath ?? this.filePath);
  }

  @override
  bool operator ==(covariant ImageToPdfToolInput other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath;
  }

  @override
  int get hashCode => filePath.hashCode;
}

extension ImageToPdfMapper on ImageToPdfToolInput {
  File get file => File(filePath);
}

extension ImageToPdfToolInputMapper on List<ImageToPdfToolInput> {
  /// Builds the engine input, keeping the order chosen by the user.
  ImageToPdfInput toImageToPdfInput({
    required ImageToPdfPageSize pageSize,
    required ImageToPdfOrientation orientation,
    required ImageToPdfFit fit,
    double margin = 10,
    int dpi = 150,
  }) {
    return ImageToPdfInput(
      images: [for (final input in this) input.file],
      pageSize: pageSize,
      orientation: orientation,
      fit: fit,
      margin: margin,
      dpi: dpi,
    );
  }
}
