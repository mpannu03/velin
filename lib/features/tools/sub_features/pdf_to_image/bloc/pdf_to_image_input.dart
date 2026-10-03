import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

/// Which pages are turned into images.
enum PdfToImagePageScope {
  allPages,
  selectedPages;

  bool get requiresSelection => this == PdfToImagePageScope.selectedPages;
}

/// User-facing model for the PDF to Image tool.
class PdfToImageToolInput {
  const PdfToImageToolInput({
    required this.filePath,
    this.scope = PdfToImagePageScope.allPages,
    this.selection = '',
    this.format = PdfImageFormat.png,
    this.colorMode = PdfImageColorMode.color,
    this.dpi = 150,
    this.quality = 90,
  });

  /// Resolutions accepted by [PdfToImageEngine].
  static const supportedDpi = [72, 150, 300, 600];

  final String filePath;
  final PdfToImagePageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`. Ignored when
  /// [scope] is [PdfToImagePageScope.allPages].
  final String selection;

  final PdfImageFormat format;
  final PdfImageColorMode colorMode;
  final int dpi;

  /// Applies to JPEG and WebP. PNG ignores this setting.
  final int quality;

  /// PNG is lossless, so the quality setting has no effect on it.
  bool get supportsQuality => format != PdfImageFormat.png;

  /// Parsed page selection, or `null` when the whole document is converted.
  ///
  /// Throws [PageSelectionError] when [selection] is empty or malformed and
  /// [scope] is [PdfToImagePageScope.selectedPages].
  PageSelection? get parsedSelection {
    if (!scope.requiresSelection) {
      return null;
    }

    if (selection.trim().isEmpty) {
      throw const EmptyPageSelectionError();
    }

    return PageSelectionParser().parse(selection);
  }

  PdfToImageToolInput copyWith({
    PdfToImagePageScope? scope,
    String? selection,
    PdfImageFormat? format,
    PdfImageColorMode? colorMode,
    int? dpi,
    int? quality,
  }) {
    return PdfToImageToolInput(
      filePath: filePath,
      scope: scope ?? this.scope,
      selection: selection ?? this.selection,
      format: format ?? this.format,
      colorMode: colorMode ?? this.colorMode,
      dpi: dpi ?? this.dpi,
      quality: quality ?? this.quality,
    );
  }
}

extension PdfToImageMapper on PdfToImageToolInput {
  PdfToImageInput toPdfToImageInput() {
    return PdfToImageInput(
      file: File(filePath),
      selection: parsedSelection,
      format: format,
      colorMode: colorMode,
      dpi: dpi,
      quality: quality,
    );
  }
}