import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';
import 'package:velin/features/home/widgets/recent_progress_bar.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Recent documents as a compact table: name, folder, progress and when
/// each was last opened. Clicking a column heading sorts by it.
class RecentTable extends StatelessWidget {
  const RecentTable({
    required this.documents,
    required this.viewModel,
    required this.sort,
    required this.onSortChanged,
    super.key,
  });

  /// Already sorted and filtered.
  final List<RecentDocument> documents;
  final HomeViewModel viewModel;
  final RecentSortMode sort;
  final ValueChanged<RecentSortMode> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: colors.surfaceContainerLow,
              child: _TableRow(
                name: _HeaderCell(
                  label: l10n.homeSortName,
                  active: sort == RecentSortMode.name,
                  onTap: () => onSortChanged(RecentSortMode.name),
                ),
                folder: _HeaderCell(label: l10n.homeColumnFolder),
                progress: _HeaderCell(
                  label: l10n.homeSortProgress,
                  active: sort == RecentSortMode.progress,
                  onTap: () => onSortChanged(RecentSortMode.progress),
                ),
                opened: _HeaderCell(
                  label: l10n.homeSortLastOpened,
                  active: sort == RecentSortMode.lastOpened,
                  onTap: () => onSortChanged(RecentSortMode.lastOpened),
                ),
              ),
            ),
            for (final doc in documents) ...[
              const Divider(),
              _DocumentRow(document: doc, viewModel: viewModel),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lays out the four columns the same way for the heading and each row.
class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.name,
    required this.folder,
    required this.progress,
    required this.opened,
  });

  final Widget name;
  final Widget folder;
  final Widget progress;
  final Widget opened;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(flex: 5, child: name),
          const SizedBox(width: AppSpacing.lg),
          Expanded(flex: 4, child: folder),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(width: 160, child: progress),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(width: 110, child: opened),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = active ? colors.onSurface : colors.onSurfaceVariant;

    final content = SizedBox(
      height: 34,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(width: AppSpacing.xxs),
            Icon(Icons.arrow_downward, size: 12, color: color),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
}

class _DocumentRow extends StatefulWidget {
  const _DocumentRow({required this.document, required this.viewModel});

  final RecentDocument document;
  final HomeViewModel viewModel;

  @override
  State<_DocumentRow> createState() => _DocumentRowState();
}

class _DocumentRowState extends State<_DocumentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final doc = widget.document;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.viewModel.onRecentDocumentSelected(doc),
        child: Container(
          height: 40,
          color: _hovered ? colors.surfaceContainerLow : colors.surface,
          child: _TableRow(
            name: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recentFileName(doc.path),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            folder: Tooltip(
              message: recentDirectory(doc.path),
              child: Text(
                recentDirectory(doc.path),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ),
            progress: Row(
              children: [
                Expanded(child: RecentProgressBar(value: recentProgress(doc))),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${doc.currentPage} / ${doc.pageCount}',
                    textAlign: TextAlign.end,
                    style: muted?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            opened: Text(
              relativeTime(doc.lastOpenedAt, context.l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
          ),
        ),
      ),
    );
  }
}
