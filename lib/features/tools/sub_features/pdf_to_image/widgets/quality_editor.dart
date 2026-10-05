import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ImageQualityEditor extends StatelessWidget {
  const ImageQualityEditor({
    super.key,
    required this.quality,
    required this.onQualityChanged,
    required this.supportsQuality,
  });

  final int quality;
  final ValueChanged<int> onQualityChanged;
  final bool supportsQuality;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // PNG is lossless: the setting has no effect, so it stays disabled.
    if (!supportsQuality) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.toolsPdfToImageQualityLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Opacity(
                  opacity: 0.5,
                  child: Slider(
                    key: const ValueKey('pdf-to-image-quality'),
                    value: quality.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '$quality',
                    onChanged: null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          HelperText(l10n.toolsPdfToImageQualityHelper),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsPdfToImageQualityLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Slider(
                key: const ValueKey('pdf-to-image-quality'),
                value: quality.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$quality',
                onChanged: (value) =>
                    onQualityChanged(value.round()),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$quality',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsPdfToImageQualityHelper),
      ],
    );
  }
}