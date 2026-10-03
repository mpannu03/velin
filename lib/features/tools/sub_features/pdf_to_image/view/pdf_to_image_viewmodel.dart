import 'package:material_ui/material_ui.dart';

import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

class PdfToImageViewModel {
  const PdfToImageViewModel({
    required this.inputFilePath,
    required this.scope,
    required this.selection,
    required this.format,
    required this.colorMode,
    required this.dpi,
    required this.quality,
    required this.supportsQuality,
    required this.outputDirectory,
    required this.isSubmitting,
    required this.canConvert,
    required this.onPickFile,
    required this.onScopeChanged,
    required this.onSelectionChanged,
    required this.onFormatChanged,
    required this.onColorModeChanged,
    required this.onDpiChanged,
    required this.onQualityChanged,
    required this.onChooseOutputFolder,
    required this.onConvert,
    required this.onBack,
  });

  final String? inputFilePath;
  final PdfToImagePageScope scope;
  final String selection;
  final PdfImageFormat format;
  final PdfImageColorMode colorMode;
  final int dpi;
  final int quality;

  /// False for PNG, which is always lossless.
  final bool supportsQuality;

  final String? outputDirectory;

  final bool isSubmitting;
  final bool canConvert;

  final VoidCallback onPickFile;
  final ValueChanged<PdfToImagePageScope> onScopeChanged;
  final ValueChanged<String> onSelectionChanged;
  final ValueChanged<PdfImageFormat> onFormatChanged;
  final ValueChanged<PdfImageColorMode> onColorModeChanged;
  final ValueChanged<int> onDpiChanged;
  final ValueChanged<int> onQualityChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onConvert;
  final VoidCallback onBack;
}