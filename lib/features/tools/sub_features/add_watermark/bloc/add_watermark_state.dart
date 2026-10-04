import 'dart:io';

import 'package:velin/engine/engine.dart';

import 'add_watermark_input.dart';

class AddWatermarkState {
  const AddWatermarkState({
    this.inputFilePath,
    this.outputDirectory,
    this.outputFileName,
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
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final String? outputDirectory;
  final String? outputFileName;

  final WatermarkType type;

  /// Text stamped when [type] is [WatermarkType.text].
  final String text;

  /// Image stamped when [type] is [WatermarkType.image].
  final String? imageFilePath;

  /// Null lets the engine use its default font.
  final String? fontName;

  final double fontSize;

  /// Six-digit hexadecimal color, with or without the leading `#`.
  final String colorHex;

  final double opacity;
  final double rotation;
  final WatermarkPosition position;
  final double xOffset;
  final double yOffset;
  final double imageWidthPercent;
  final WatermarkLayer layer;

  final WatermarkPageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`.
  final String selection;

  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  bool get hasValidSelection => selection.trim().isNotEmpty;

  bool get hasValidScopeConfig =>
      scope.requiresSelection ? hasValidSelection : true;

  /// The image watermark is only used by [WatermarkType.image].
  bool get hasWatermarkContent => type == WatermarkType.text
      ? text.trim().isNotEmpty
      : imageFilePath != null && imageFilePath!.trim().isNotEmpty;

  /// A malformed color can still be typed, but the tool stays disabled.
  bool get hasValidColor =>
      AddWatermarkToolInput.colorHexPattern.hasMatch(colorHex.trim());

  bool get canApplyWatermark =>
      hasInputFile &&
      hasWatermarkContent &&
      hasValidColor &&
      hasValidScopeConfig &&
      hasValidOutputDirectory &&
      hasValidOutputFileName &&
      !isSubmitting;

  /// The tool input for the current state.
  ///
  /// [outputDirectory] and [outputFileName] are joined here so the cubit and
  /// the view agree on the final path.
  AddWatermarkToolInput get toolInput {
    final directory = outputDirectory!.trim().replaceFirst(
      RegExp(r'[/\\]+$'),
      '',
    );

    return AddWatermarkToolInput(
      filePath: inputFilePath!.trim(),
      outputFilePath:
          '$directory${Platform.pathSeparator}'
          '${outputFileName!.trim()}',
      type: type,
      text: text,
      imageFilePath: imageFilePath,
      fontName: fontName,
      fontSize: fontSize,
      colorHex: colorHex,
      opacity: opacity,
      rotation: rotation,
      position: position,
      xOffset: xOffset,
      yOffset: yOffset,
      imageWidthPercent: imageWidthPercent,
      layer: layer,
      scope: scope,
      selection: selection,
    );
  }

  AddWatermarkState copyWith({
    Object? inputFilePath = _unset,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
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
    bool? isSubmitting,
  }) {
    return AddWatermarkState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
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
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();