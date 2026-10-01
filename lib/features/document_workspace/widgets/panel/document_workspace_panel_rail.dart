import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/shared/extensions/extensions.dart';
import 'package:velin/shared/utils/utils.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../models/models.dart';
import 'page_indicator.dart';

class DocumentWorkspacePanelRail extends StatelessWidget {
  const DocumentWorkspacePanelRail({
    required this.selectedPanel,
    required this.capabilities,
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
  final DocumentEngineCapabilities capabilities;

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
            if (capabilities.comments)
              VelinIconButton(
                icon: Symbols.comment,
                tooltip: context.l10n.panelComments,
                onPressed: () => onPanelSelected(WorkspacePanel.comments),
                isSelected: selectedPanel == WorkspacePanel.comments,
              ),
            if (capabilities.bookmarks)
              VelinIconButton(
                icon: Symbols.bookmark,
                tooltip: context.l10n.panelBookmarks,
                onPressed: () => onPanelSelected(WorkspacePanel.bookmarks),
                isSelected: selectedPanel == WorkspacePanel.bookmarks,
              ),
            if (capabilities.search)
              VelinIconButton(
                icon: Symbols.search,
                tooltip: context.l10n.panelSearch,
                onPressed: () => onPanelSelected(WorkspacePanel.search),
                isSelected: selectedPanel == WorkspacePanel.search,
              ),
            VelinIconButton(
              icon: Symbols.dictionary,
              tooltip: context.l10n.panelDictionary,
              onPressed: () => onPanelSelected(WorkspacePanel.dictionary),
              isSelected: selectedPanel == WorkspacePanel.dictionary,
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
              tooltip: context.l10n.toolZoomIn,
              onPressed: zoomIn,
            ),
            Text(getPercentagefromDouble(currentZoom),
              style: textTheme.labelSmall,
            ),
            VelinIconButton(
              icon: Icons.zoom_out_outlined,
              tooltip: context.l10n.toolZoomOut,
              onPressed: zoomOut,
            )
          ],
        ),
      ),
    );
  }
}