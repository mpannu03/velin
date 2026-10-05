import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

class WatermarkContentEditor extends StatelessWidget {
  const WatermarkContentEditor({
    super.key,
    required this.type,
    required this.text,
    required this.imageFilePath,
    required this.fontName,
    required this.fontSize,
    required this.colorHex,
    required this.imageWidthPercent,
    required this.onTypeChanged,
    required this.onTextChanged,
    required this.onFontNameChanged,
    required this.onFontSizeChanged,
    required this.onColorHexChanged,
    required this.onPickWatermarkImage,
    required this.onClearWatermarkImage,
    required this.onImageWidthPercentChanged,
  });

  final WatermarkType type;

  final String text;

  /// Image stamped when [type] is [WatermarkType.image].
  final String? imageFilePath;

  /// Null lets the engine use its default font.
  final String? fontName;

  final double fontSize;

  /// Six-digit hexadecimal color, with or without the leading `#`.
  final String colorHex;

  final double imageWidthPercent;

  final ValueChanged<WatermarkType> onTypeChanged;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onFontNameChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onColorHexChanged;
  final VoidCallback onPickWatermarkImage;
  final VoidCallback onClearWatermarkImage;
  final ValueChanged<double> onImageWidthPercentChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WatermarkType>(
          key: const ValueKey('add-watermark-type'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkType.text,
              icon: const Icon(Icons.text_fields, size: 18),
              label: Text(l10n.toolsWatermarkTypeText),
            ),
            ButtonSegment(
              value: WatermarkType.image,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(l10n.toolsWatermarkTypeImage),
            ),
          ],
          selected: {type},
          onSelectionChanged: (selection) => onTypeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (type == WatermarkType.text)
          TextWatermarkEditor(
            text: text,
            fontName: fontName,
            fontSize: fontSize,
            colorHex: colorHex,
            onTextChanged: onTextChanged,
            onFontNameChanged: onFontNameChanged,
            onFontSizeChanged: onFontSizeChanged,
            onColorHexChanged: onColorHexChanged,
          )
        else
          ImageWatermarkEditor(
            imageFilePath: imageFilePath,
            imageWidthPercent: imageWidthPercent,
            onPickWatermarkImage: onPickWatermarkImage,
            onClearWatermarkImage: onClearWatermarkImage,
            onImageWidthPercentChanged: onImageWidthPercentChanged,
          ),
      ],
    );
  }
}
