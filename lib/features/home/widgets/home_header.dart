import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Page title with the Home actions: open a document or go to the tools.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.docCount,
    required this.isOpening,
    required this.onOpenDocument,
    required this.onBrowseTools,
    super.key,
  });

  final int docCount;
  final bool isOpening;
  final VoidCallback onOpenDocument;
  final VoidCallback onBrowseTools;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                docCount == 0 ? l10n.homeTitleEmpty : l10n.homeTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                docCount == 0
                    ? l10n.homeSubtitleEmpty
                    : l10n.homeSubtitle(docCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: onBrowseTools,
              icon: const Icon(Icons.construction_outlined, size: 18),
              label: Text(l10n.homeBrowseTools),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.icon(
              onPressed: isOpening ? null : onOpenDocument,
              icon: isOpening
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open_outlined, size: 18),
              label: Text(isOpening ? l10n.homeOpening : l10n.homeOpenDocument),
            ),
          ],
        ),
      ],
    );
  }
}
