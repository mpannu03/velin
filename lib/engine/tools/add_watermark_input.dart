import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';

enum WatermarkType { text, image }

enum WatermarkPosition { center, topLeft, topRight, bottomLeft, bottomRight }

enum WatermarkLayer { foreground, background }

class AddWatermarkInput {
  const AddWatermarkInput({
    required this.file,
    required this.outputFile,
    this.type = WatermarkType.text,
    this.text = 'CONFIDENTIAL',
    this.imageFile,
    this.fontName,
    this.fontSize = 48,
    this.colorHex = '#808080',
    this.opacity = 0.3,
    this.rotation = -45,
    this.position = WatermarkPosition.center,
    this.xOffset = 0,
    this.yOffset = 0,
    this.imageWidthPercent = 30,
    this.layer = WatermarkLayer.foreground,
    this.selection,
  }) : assert(fontSize > 0),
       assert(opacity >= 0.05 && opacity <= 1),
       assert(imageWidthPercent > 0 && imageWidthPercent <= 100);

  final File file;
  final File outputFile;

  final WatermarkType type;

  final String text;
  final File? imageFile;

  final String? fontName;
  final double fontSize;
  final String colorHex;

  /// 0.05 = 5%, 1.0 = 100%.
  final double opacity;

  /// Degrees. Positive = clockwise.
  final double rotation;

  final WatermarkPosition position;

  /// Offset from the selected anchor, in PDF points.
  final double xOffset;
  final double yOffset;

  /// Image width as a percentage of the page width.
  final double imageWidthPercent;

  final WatermarkLayer layer;

  /// Null means all pages.
  final PageSelection? selection;
}
