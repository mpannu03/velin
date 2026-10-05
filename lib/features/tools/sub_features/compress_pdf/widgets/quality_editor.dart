import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

class QualityEditor extends StatelessWidget {
  const QualityEditor({
    super.key,
    required this.quality,
    required this.onQualityChanged,
  });

  final int quality;
  final ValueChanged<int> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsCompressQualityLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Slider(
                key: const ValueKey('compress-pdf-quality'),
                value: quality.toDouble(),
                min: CompressPdfToolInput.minQuality.toDouble(),
                max: CompressPdfToolInput.maxQuality.toDouble(),
                divisions:
                    CompressPdfToolInput.maxQuality -
                    CompressPdfToolInput.minQuality,
                label: '$quality',
                onChanged: (value) => onQualityChanged(value.round()),
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
        Text(
          l10n.toolsCompressQualityHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
