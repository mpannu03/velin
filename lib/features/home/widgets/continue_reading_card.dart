import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';
import 'package:velin/features/home/widgets/recent_progress_bar.dart';
import 'package:velin/features/home/widgets/recent_thumbnail.dart';

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    required this.document,
    required this.viewModel,
    super.key,
  });

  final RecentDocument document;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = recentProgress(document);
    final pct = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 148,
            height: 190,
            child: RecentThumbnail(
              path: document.path,
              loader: viewModel.thumbnailLoader,
              borderRadius: AppRadius.md,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'CONTINUE READING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  recentFileName(document.path),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Page ${document.currentPage} of ${document.pageCount} · $pct% · ${relativeTime(document.lastOpenedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                RecentProgressBar(value: progress, height: 6),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: viewModel.isOpening
                          ? null
                          : () => viewModel.onRecentDocumentSelected(document),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Resume'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: viewModel.onOpenDocument,
                      icon: const Icon(Icons.folder_open_outlined, size: 18),
                      label: const Text('Open another'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
