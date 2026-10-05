import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

/// Opacity, rotation, position, offsets and layer. Everything here applies to
/// both text and image watermarks.
class StyleEditor extends StatelessWidget {
  const StyleEditor({
    super.key,
    required this.opacity,
    required this.rotation,
    required this.position,
    required this.xOffset,
    required this.yOffset,
    required this.layer,
    required this.onOpacityChanged,
    required this.onRotationChanged,
    required this.onPositionChanged,
    required this.onXOffsetChanged,
    required this.onYOffsetChanged,
    required this.onLayerChanged,
  });

  final double opacity;
  final double rotation;
  final WatermarkPosition position;
  final double xOffset;
  final double yOffset;
  final WatermarkLayer layer;

  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onRotationChanged;
  final ValueChanged<WatermarkPosition> onPositionChanged;
  final ValueChanged<double> onXOffsetChanged;
  final ValueChanged<double> onYOffsetChanged;
  final ValueChanged<WatermarkLayer> onLayerChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledSlider(
          label: l10n.toolsWatermarkOpacityLabel,
          value: opacity,
          min: AddWatermarkToolInput.minOpacity,
          max: AddWatermarkToolInput.maxOpacity,
          divisions: 19,
          displayValue: '${(opacity * 100).round()}%',
          sliderKey: const ValueKey('add-watermark-opacity'),
          onChanged: onOpacityChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledSlider(
          label: l10n.toolsWatermarkRotationLabel,
          value: rotation,
          min: AddWatermarkToolInput.minRotation,
          max: AddWatermarkToolInput.maxRotation,
          divisions: 72,
          displayValue: '${rotation.round()}\u00b0',
          sliderKey: const ValueKey('add-watermark-rotation'),
          onChanged: onRotationChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsWatermarkRotationHelper),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.toolsWatermarkPositionLabel),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in _positionEntries(context))
              ChoiceChip(
                label: Text(entry.label),
                selected: position == entry.position,
                onSelected: (_) => onPositionChanged(entry.position),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LabeledSlider(
          label: l10n.toolsWatermarkOffsetXLabel,
          value: xOffset,
          min: AddWatermarkToolInput.minOffset,
          max: AddWatermarkToolInput.maxOffset,
          divisions: 60,
          displayValue: xOffset.round().toString(),
          sliderKey: const ValueKey('add-watermark-offset-x'),
          onChanged: onXOffsetChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledSlider(
          label: l10n.toolsWatermarkOffsetYLabel,
          value: yOffset,
          min: AddWatermarkToolInput.minOffset,
          max: AddWatermarkToolInput.maxOffset,
          divisions: 60,
          displayValue: yOffset.round().toString(),
          sliderKey: const ValueKey('add-watermark-offset-y'),
          onChanged: onYOffsetChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsWatermarkOffsetHelper),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.toolsWatermarkLayerLabel),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<WatermarkLayer>(
          key: const ValueKey('add-watermark-layer'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkLayer.foreground,
              icon: const Icon(Icons.layers_outlined, size: 18),
              label: Text(l10n.toolsWatermarkLayerForeground),
            ),
            ButtonSegment(
              value: WatermarkLayer.background,
              icon: const Icon(Icons.layers_clear_outlined, size: 18),
              label: Text(l10n.toolsWatermarkLayerBackground),
            ),
          ],
          selected: {layer},
          onSelectionChanged: (selection) => onLayerChanged(selection.first),
        ),
      ],
    );
  }
}

/// Localized labels for every [WatermarkPosition], in enum order.
List<({WatermarkPosition position, String label})> _positionEntries(
  BuildContext context,
) {
  final l10n = context.l10n;

  return [
    (
      position: WatermarkPosition.center,
      label: l10n.toolsWatermarkPositionCenter,
    ),
    (
      position: WatermarkPosition.topLeft,
      label: l10n.toolsWatermarkPositionTopLeft,
    ),
    (
      position: WatermarkPosition.topRight,
      label: l10n.toolsWatermarkPositionTopRight,
    ),
    (
      position: WatermarkPosition.bottomLeft,
      label: l10n.toolsWatermarkPositionBottomLeft,
    ),
    (
      position: WatermarkPosition.bottomRight,
      label: l10n.toolsWatermarkPositionBottomRight,
    ),
  ];
}