import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';
import 'package:velin/features/home/widgets/recent_progress_bar.dart';
import 'package:velin/features/home/widgets/recent_thumbnail.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// One row of page covers for the most recently opened documents; as many
/// as fit the width, up to [maxItems].
class RecentShelf extends StatelessWidget {
  const RecentShelf({
    required this.documents,
    required this.viewModel,
    this.maxItems = 6,
    super.key,
  });

  /// Most recent first.
  final List<RecentDocument> documents;
  final HomeViewModel viewModel;
  final int maxItems;

  static const _minItemWidth = 148.0;
  static const _gap = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + _gap) / (_minItemWidth + _gap))
            .floor()
            .clamp(1, maxItems);
        final itemWidth = (width - _gap * (columns - 1)) / columns;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, doc) in documents.take(columns).indexed) ...[
              if (index > 0) const SizedBox(width: _gap),
              SizedBox(
                width: itemWidth,
                child: _ShelfItem(document: doc, viewModel: viewModel),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ShelfItem extends StatefulWidget {
  const _ShelfItem({required this.document, required this.viewModel});

  final RecentDocument document;
  final HomeViewModel viewModel;

  @override
  State<_ShelfItem> createState() => _ShelfItemState();
}

class _ShelfItemState extends State<_ShelfItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final doc = widget.document;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.viewModel.onRecentDocumentSelected(doc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A page sitting on the surface: a hairline edge and a soft
            // shadow that lifts a little on hover.
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: _hovered ? colors.outline : colors.outlineVariant,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(
                      alpha: _hovered ? 0.16 : 0.06,
                    ),
                    blurRadius: _hovered ? 12 : 4,
                    offset: Offset(0, _hovered ? 4 : 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: AspectRatio(
                  // Close to A4 / Letter portrait.
                  aspectRatio: 1 / 1.3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecentThumbnail(
                        path: doc.path,
                        loader: widget.viewModel.thumbnailLoader,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RecentProgressBar(
                          value: recentProgress(doc),
                          height: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              recentFileName(doc.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: _hovered ? colors.primary : colors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${context.l10n.homePageProgress(doc.currentPage, doc.pageCount)}'
              ' · ${relativeTime(doc.lastOpenedAt, context.l10n)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
