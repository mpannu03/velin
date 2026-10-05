import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

/// One-tap swatches plus a free-form `#RRGGBB` field.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.colorHex,
    required this.onColorHexChanged,
  });

  final String colorHex;
  final ValueChanged<String> onColorHexChanged;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.colorHex);
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The state is the source of truth: a rejected hex is not echoed back
    // into the field, so only push when the two actually diverge.
    if (widget.colorHex != _controller.text) {
      _controller.text = widget.colorHex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit(String value) {
    widget.onColorHexChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentHex = widget.colorHex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.toolsWatermarkColorLabel),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final hex in AddWatermarkToolInput.commonColors)
              VColorSwatch(
                hex: hex,
                isSelected: hex.toUpperCase() == normalizeHexColor(currentHex),
                onTap: () => _commit(hex),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorFromHex(currentHex),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Icon(
                Icons.colorize,
                size: 18,
                color: contrastColorFromHex(currentHex),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                key: const ValueKey('add-watermark-color-hex'),
                controller: _controller,
                onSubmitted: _commit,
                onTapOutside: (_) => _commit(_controller.text),
                decoration: InputDecoration(
                  labelText: l10n.toolsWatermarkColorLabel,
                  hintText: l10n.toolsWatermarkColorHint,
                  prefixText: '#',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
