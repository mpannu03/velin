import 'package:velin/engine/engine.dart';

import 'pdf_to_image_input.dart';

class PdfToImageState {
  const PdfToImageState({
    this.inputFilePath,
    this.scope = PdfToImagePageScope.allPages,
    this.selection = '',
    this.format = PdfImageFormat.png,
    this.colorMode = PdfImageColorMode.color,
    this.dpi = 150,
    this.quality = 90,
    this.outputDirectory,
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final PdfToImagePageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`.
  final String selection;

  final PdfImageFormat format;
  final PdfImageColorMode colorMode;
  final int dpi;

  /// Applies to JPEG and WebP. PNG ignores this setting.
  final int quality;

  final String? outputDirectory;
  final bool isSubmitting;

  /// PNG is lossless, so quality only matters for the other formats.
  bool get supportsQuality => format != PdfImageFormat.png;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidSelection => selection.trim().isNotEmpty;

  bool get hasValidScopeConfig =>
      scope.requiresSelection ? hasValidSelection : true;

  bool get canConvert =>
      hasInputFile &&
      hasValidScopeConfig &&
      hasValidOutputDirectory &&
      !isSubmitting;

  PdfToImageState copyWith({
    Object? inputFilePath = _unset,
    PdfToImagePageScope? scope,
    String? selection,
    PdfImageFormat? format,
    PdfImageColorMode? colorMode,
    int? dpi,
    int? quality,
    Object? outputDirectory = _unset,
    bool? isSubmitting,
  }) {
    return PdfToImageState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      scope: scope ?? this.scope,
      selection: selection ?? this.selection,
      format: format ?? this.format,
      colorMode: colorMode ?? this.colorMode,
      dpi: dpi ?? this.dpi,
      quality: quality ?? this.quality,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();