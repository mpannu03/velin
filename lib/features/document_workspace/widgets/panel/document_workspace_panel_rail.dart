import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/utils/utils.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../models/models.dart';
import 'page_indicator.dart';

class DocumentWorkspacePanelRail extends StatelessWidget {
  const DocumentWorkspacePanelRail({
    required this.selectedPanel,
    required this.currentPage,
    required this.pageCount,
    required this.currentZoom,
    required this.zoomIn,
    required this.zoomOut,
    required this.onPanelSelected,
    required this.onGotoPage,
    super.key,
  });

  final WorkspacePanel? selectedPanel;

  final int? currentPage;
  final int pageCount;
  final double currentZoom;

  final VoidCallback zoomIn;
  final VoidCallback zoomOut;

  final ValueChanged<WorkspacePanel> onPanelSelected;
  final ValueChanged<int> onGotoPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            PageIndicator(
              currentPage: currentPage, 
              pageCount: pageCount,
              onGotoPage: onGotoPage,
            ),
            SizedBox(height: AppSpacing.md),
            VelinIconButton(
              icon: Icons.zoom_in_outlined,
              tooltip: 'Zoom',
              onPressed: zoomIn,
            ),
            Text(getPercentagefromDouble(currentZoom),
              style: textTheme.labelSmall,
            ),
            VelinIconButton(
              icon: Icons.zoom_out_outlined,
              tooltip: 'Zoom Out',
              onPressed: zoomOut,
            )
          ],
        ),
      ),
    );
  }
}