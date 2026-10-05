import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

class AddWatermarkViewModel {
  const AddWatermarkViewModel({
    required this.inputFilePath,
    required this.outputFileName,
    required this.outputDirectory,
    required this.type,
    required this.text,
    required this.imageFilePath,
    required this.fontName,
    required this.fontSize,
    required this.colorHex,
    required this.opacity,
    required this.rotation,
    required this.position,
    required this.xOffset,
    required this.yOffset,
    required this.imageWidthPercent,
    required this.layer,
    required this.scope,
    required this.selection,
    required this.isSubmitting,
    required this.canApplyWatermark,
    required this.onPickFile,
    required this.onPickWatermarkImage,
    required this.onClearWatermarkImage,
    required this.onTypeChanged,
    required this.onTextChanged,
    required this.onFontNameChanged,
    required this.onFontSizeChanged,
    required this.onColorHexChanged,
    required this.onOpacityChanged,
    required this.onRotationChanged,
    required this.onPositionChanged,
    required this.onXOffsetChanged,
    required this.onYOffsetChanged,
    required this.onImageWidthPercentChanged,
    required this.onLayerChanged,
    required this.onScopeChanged,
    required this.onSelectionChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onApplyWatermark,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? outputFileName;
  final String? outputDirectory;

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
  final bool canApplyWatermark;

  final VoidCallback onPickFile;
  final VoidCallback onPickWatermarkImage;
  final VoidCallback onClearWatermarkImage;
  final ValueChanged<WatermarkType> onTypeChanged;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onFontNameChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onColorHexChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onRotationChanged;
  final ValueChanged<WatermarkPosition> onPositionChanged;
  final ValueChanged<double> onXOffsetChanged;
  final ValueChanged<double> onYOffsetChanged;
  final ValueChanged<double> onImageWidthPercentChanged;
  final ValueChanged<WatermarkLayer> onLayerChanged;
  final ValueChanged<WatermarkPageScope> onScopeChanged;
  final ValueChanged<String> onSelectionChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onApplyWatermark;
  final VoidCallback onBack;
}
