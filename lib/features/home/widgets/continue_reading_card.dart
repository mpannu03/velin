import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';
import 'package:velin/features/home/widgets/recent_progress_bar.dart';
import 'package:velin/features/home/widgets/recent_thumbnail.dart';
import 'package:velin/shared/extensions/extensions.dart';

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
                Text(
                  context.l10n.homeContinueReading.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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
                  '${context.l10n.homePageProgress(document.currentPage, document.pageCount)} · $pct% · ${relativeTime(document.lastOpenedAt, context.l10n)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                RecentProgressBar(value: progress, height: 6),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: viewModel.isOpening
                      ? null
                      : () => viewModel.onRecentDocumentSelected(document),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(context.l10n.homeResume),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
