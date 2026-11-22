import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/widgets/home_header.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Home before anything was opened: a short invitation with the two ways
/// in, centred in the page.
class RecentEmptyState extends StatelessWidget {
  const RecentEmptyState({
    required this.isOpening,
    required this.onOpenDocument,
    required this.onBrowseTools,
    super.key,
  });

  final bool isOpening;
  final VoidCallback onOpenDocument;
  final VoidCallback onBrowseTools;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 40,
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.homeTitleEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.homeSubtitleEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: onBrowseTools,
                  child: Text(l10n.homeBrowseTools),
                ),
                const SizedBox(width: AppSpacing.sm),
                HomeOpenButton(isOpening: isOpening, onPressed: onOpenDocument),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
