import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

/// Which pages receive the watermark.
enum WatermarkPageScope {
  allPages,
  selectedPages;

  bool get requiresSelection => this == WatermarkPageScope.selectedPages;
}

/// User-facing model for the Watermark tool.
class AddWatermarkToolInput {
  const AddWatermarkToolInput({
    required this.filePath,
    required this.outputFilePath,
    this.type = WatermarkType.text,
    this.text = 'CONFIDENTIAL',
    this.imageFilePath,
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
    this.scope = WatermarkPageScope.allPages,
    this.selection = '',
  });

  /// Font sizes accepted by [AddWatermarkEngine].
  static const minFontSize = 8;
  static const maxFontSize = 200;

  /// Opacity range accepted by [AddWatermarkEngine].
  static const minOpacity = 0.05;
  static const maxOpacity = 1.0;

  /// Rotation range offered by the UI, in degrees.
  static const minRotation = -180.0;
  static const maxRotation = 180.0;

  /// Offset range offered by the UI, in PDF points.
  static const minOffset = -300.0;
  static const maxOffset = 300.0;

  /// Image width range accepted by [AddWatermarkEngine], as a percentage of
  /// the page width.
  static const minImageWidthPercent = 5.0;
  static const maxImageWidthPercent = 100.0;

  /// Image extensions [AddWatermarkEngine] can decode.
  static const supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'tif',
    'tiff',
  ];

  /// Fonts offered by the dropdown. The engine falls back to its default
  /// sans-serif font when `fontName` is null, which the empty entry maps to.
  static const supportedFonts = [
    null,
    'Helvetica',
    'Helvetica-Bold',
    'Times-Roman',
    'Times-Bold',
    'Times-Italic',
    'Courier',
    'Courier-Bold',
    'Courier-Oblique',
  ];

  /// A short palette offered as one-tap color swatches.
  static const commonColors = [
    '#000000',
    '#FFFFFF',
    '#808080',
    '#FF0000',
    '#FF6B00',
    '#FFD400',
    '#2F9E44',
    '#0B7285',
    '#1C7ED6',
    '#4C6EF5',
    '#7048E8',
    '#D6336C',
  ];

  /// A six-digit hexadecimal color, with or without the leading `#`.
  static final colorHexPattern = RegExp(r'^#?[0-9a-fA-F]{6}$');

  final String filePath;
  final String outputFilePath;

  final WatermarkType type;

  /// Text to stamp. Only used when [type] is [WatermarkType.text].
  final String text;

  /// Path of the image to stamp. Only used when [type] is
  /// [WatermarkType.image].
  final String? imageFilePath;

  /// Null lets the engine use its default font.
  final String? fontName;

  /// Text size in points.
  final double fontSize;

  /// Six-digit hexadecimal color, with or without the leading `#`.
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

  final WatermarkPageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`. Ignored when [scope] is
  /// [WatermarkPageScope.allPages].
  final String selection;

  /// True when the watermark has the content the engine needs for [type].
  bool get hasWatermarkContent => type == WatermarkType.text
      ? text.trim().isNotEmpty
      : imageFilePath != null && imageFilePath!.trim().isNotEmpty;

  /// True when [colorHex] can be handed to the engine.
  bool get hasValidColor => colorHexPattern.hasMatch(colorHex.trim());

  /// Parsed page selection, or `null` when every page is watermarked.
  ///
  /// Throws [PageSelectionError] when [selection] is empty or malformed and
  /// [scope] is [WatermarkPageScope.selectedPages].
  PageSelection? get parsedSelection {
    if (!scope.requiresSelection) {
      return null;
    }

    if (selection.trim().isEmpty) {
      throw const EmptyPageSelectionError();
    }

    return PageSelectionParser().parse(selection);
  }

  AddWatermarkToolInput copyWith({
    String? filePath,
    String? outputFilePath,
    WatermarkType? type,
    String? text,
    Object? imageFilePath = _unset,
    Object? fontName = _unset,
    double? fontSize,
    String? colorHex,
    double? opacity,
    double? rotation,
    WatermarkPosition? position,
    double? xOffset,
    double? yOffset,
    double? imageWidthPercent,
    WatermarkLayer? layer,
    WatermarkPageScope? scope,
    String? selection,
  }) {
    return AddWatermarkToolInput(
      filePath: filePath ?? this.filePath,
      outputFilePath: outputFilePath ?? this.outputFilePath,
      type: type ?? this.type,
      text: text ?? this.text,
      imageFilePath: identical(imageFilePath, _unset)
          ? this.imageFilePath
          : imageFilePath as String?,
      fontName: identical(fontName, _unset)
          ? this.fontName
          : fontName as String?,
      fontSize: fontSize ?? this.fontSize,
      colorHex: colorHex ?? this.colorHex,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      position: position ?? this.position,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
      imageWidthPercent: imageWidthPercent ?? this.imageWidthPercent,
      layer: layer ?? this.layer,
      scope: scope ?? this.scope,
      selection: selection ?? this.selection,
    );
  }
}

extension AddWatermarkMapper on AddWatermarkToolInput {
  AddWatermarkInput toAddWatermarkInput() {
    return AddWatermarkInput(
      file: File(filePath),
      outputFile: File(outputFilePath),
      type: type,
      text: text,
      imageFile: imageFilePath == null ? null : File(imageFilePath!),
      fontName: fontName,
      fontSize: fontSize,
      colorHex: normalizeHexColor(colorHex),
      opacity: opacity,
      rotation: rotation,
      position: position,
      xOffset: xOffset,
      yOffset: yOffset,
      imageWidthPercent: imageWidthPercent,
      layer: layer,
      selection: parsedSelection,
    );
  }
}

/// Strips the optional leading `#` so the engine always receives the six
/// digits it expects.
String normalizeHexColor(String value) {
  return value.trim().replaceFirst('#', '').toUpperCase();
}

const _unset = Object();
