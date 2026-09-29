import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../models/models.dart';

class DocumentWorkspacePanelRail extends StatelessWidget {
  const DocumentWorkspacePanelRail({
    required this.selectedPanel,
    required this.currentPage,
    required this.pageCount,
    required this.onPanelSelected,
    super.key,
  });

  final WorkspacePanel? selectedPanel;

  final int? currentPage;
  final int pageCount;

  final ValueChanged<WorkspacePanel> onPanelSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            VelinIconButton(
              icon: Icons.comment_outlined,
              tooltip: 'Comments',
              onPressed: () => onPanelSelected(WorkspacePanel.comments),
              isSelected: selectedPanel == WorkspacePanel.comments,
            ),
            VelinIconButton(
              icon: Icons.sticky_note_2_outlined,
              tooltip: 'Annotations',
              onPressed: () => onPanelSelected(WorkspacePanel.annotations),
              isSelected: selectedPanel == WorkspacePanel.annotations,
            ),
            Spacer(),
            _PageIndicator(
              currentPage: currentPage, 
              pageCount: pageCount
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  final int? currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Nothing meaningful to show before a page is known.
    if (currentPage == null || pageCount == 0) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Page $currentPage of $pageCount',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentPage',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Container(
            width: 16,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: colorScheme.outlineVariant,
          ),
          Text(
            '$pageCount',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}