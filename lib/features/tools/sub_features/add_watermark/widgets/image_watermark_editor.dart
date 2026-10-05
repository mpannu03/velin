import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

class ImageWatermarkEditor extends StatelessWidget {
  const ImageWatermarkEditor({
    super.key,
    required this.imageFilePath,
    required this.imageWidthPercent,
    required this.onPickWatermarkImage,
    required this.onClearWatermarkImage,
    required this.onImageWidthPercentChanged,
  });

  final String? imageFilePath;
  final double imageWidthPercent;

  final VoidCallback onPickWatermarkImage;
  final VoidCallback onClearWatermarkImage;
  final ValueChanged<double> onImageWidthPercentChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasImage = imageFilePath != null && imageFilePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          SelectedImageRow(
            filePath: imageFilePath!,
            onReplace: onPickWatermarkImage,
            onRemove: onClearWatermarkImage,
          )
        else
          ImageEmptyState(onPickImage: onPickWatermarkImage),
        const SizedBox(height: AppSpacing.lg),
        LabeledSlider(
          label: l10n.toolsWatermarkImageWidthLabel,
          value: imageWidthPercent,
          min: AddWatermarkToolInput.minImageWidthPercent,
          max: AddWatermarkToolInput.maxImageWidthPercent,
          divisions: 19,
          displayValue: '${imageWidthPercent.round()}%',
          sliderKey: const ValueKey('add-watermark-image-width'),
          onChanged: onImageWidthPercentChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsWatermarkImageWidthHelper),
      ],
    );
  }
}