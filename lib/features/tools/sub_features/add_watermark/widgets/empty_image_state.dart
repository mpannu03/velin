import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ImageEmptyState extends StatelessWidget {
  const ImageEmptyState({super.key, required this.onPickImage});

  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 26,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsWatermarkImageDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('add-watermark-pick-image'),
            onPressed: onPickImage,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsWatermarkImageChoose),
          ),
        ],
      ),
    );
  }
}
