import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

class TextWatermarkEditor extends StatefulWidget {
  const TextWatermarkEditor({
    super.key,
    required this.text,
    required this.fontName,
    required this.fontSize,
    required this.colorHex,
    required this.onTextChanged,
    required this.onFontNameChanged,
    required this.onFontSizeChanged,
    required this.onColorHexChanged,
  });

  final String text;

  /// Null lets the engine use its default font.
  final String? fontName;

  final double fontSize;

  /// Six-digit hexadecimal color, with or without the leading `#`.
  final String colorHex;

  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onFontNameChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onColorHexChanged;

  @override
  State<TextWatermarkEditor> createState() => _TextWatermarkEditorState();
}

class _TextWatermarkEditorState extends State<TextWatermarkEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(TextWatermarkEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only push when the two diverge, otherwise the caret jumps to the end
    // on every keystroke.
    if (widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('add-watermark-text'),
          controller: _controller,
          onChanged: widget.onTextChanged,
          decoration: InputDecoration(
            labelText: l10n.toolsWatermarkTextLabel,
            hintText: l10n.toolsWatermarkTextHint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text(l10n.toolsWatermarkFontLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FontDropdown(
                fontName: widget.fontName,
                onFontNameChanged: widget.onFontNameChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LabeledSlider(
          label: l10n.toolsWatermarkFontSizeLabel,
          value: widget.fontSize,
          min: AddWatermarkToolInput.minFontSize.toDouble(),
          max: AddWatermarkToolInput.maxFontSize.toDouble(),
          divisions:
              AddWatermarkToolInput.maxFontSize -
              AddWatermarkToolInput.minFontSize,
          displayValue: widget.fontSize.round().toString(),
          sliderKey: const ValueKey('add-watermark-font-size'),
          onChanged: widget.onFontSizeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        ColorPicker(
          colorHex: widget.colorHex,
          onColorHexChanged: widget.onColorHexChanged,
        ),
      ],
    );
  }
}