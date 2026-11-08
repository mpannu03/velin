import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';
import 'package:velin/shared/utils/utils.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../models/models.dart';
import '../view/document_workspace_view_model.dart';
import 'panel/page_indicator.dart';

/// The reader's single toolbar:
///
/// `[tools] ……… [‹ page / total ›] | [− zoom% +] | [fit width][fit page] ……… [panels]`
class DocumentWorkspaceToolbar extends StatelessWidget {
  const DocumentWorkspaceToolbar({required this.viewModel, super.key});

  final DocumentWorkspaceViewModel viewModel;

  static const height = 40.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: context.l10n.readerToolbar,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _Tools(viewModel: viewModel),
              ),
            ),
            _Navigation(viewModel: viewModel),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _Panels(viewModel: viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tools extends StatelessWidget {
  const _Tools({required this.viewModel});

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxs,
      children: [
        ToolbarIconButton(
          icon: Symbols.arrow_selector_tool,
          tooltip: l10n.toolSelect,
          isSelected: viewModel.selectedTool == WorkspaceTool.select,
          onPressed: () => viewModel.onToolSelected(WorkspaceTool.select),
        ),
        if (viewModel.capabilities.textSelection)
          ToolbarIconButton(
            icon: Symbols.dictionary,
            tooltip: l10n.toolDictionary,
            isSelected: viewModel.selectedTool == WorkspaceTool.dictionary,
            onPressed: () => viewModel.onToolSelected(WorkspaceTool.dictionary),
          ),
      ],
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.viewModel});

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final page = viewModel.currentPage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToolbarIconButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: l10n.toolPreviousPage,
          onPressed: page != null && page > 1 ? viewModel.previousPage : null,
        ),
        PageIndicator(
          currentPage: page,
          pageCount: viewModel.pageCount,
          onGotoPage: viewModel.onGotoPage,
        ),
        ToolbarIconButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: l10n.toolNextPage,
          onPressed: page != null && page < viewModel.pageCount
              ? viewModel.nextPage
              : null,
        ),
        const _Separator(),
        ToolbarIconButton(
          icon: Icons.remove,
          tooltip: l10n.toolZoomOut,
          onPressed: viewModel.zoomOut,
        ),
        SizedBox(
          width: 48,
          child: Text(
            getPercentagefromDouble(viewModel.currentZoom),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
        ToolbarIconButton(
          icon: Icons.add,
          tooltip: l10n.toolZoomIn,
          onPressed: viewModel.zoomIn,
        ),
        const _Separator(),
        ToolbarIconButton(
          icon: Symbols.fit_page_width,
          tooltip: l10n.toolFitWidth,
          onPressed: viewModel.fitWidth,
        ),
        ToolbarIconButton(
          icon: Symbols.fit_page,
          tooltip: l10n.toolFitPage,
          onPressed: viewModel.fitPage,
        ),
      ],
    );
  }
}

class _Panels extends StatelessWidget {
  const _Panels({required this.viewModel});

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final capabilities = viewModel.capabilities;

    Widget toggle(WorkspacePanel panel, IconData icon) => ToolbarIconButton(
      icon: icon,
      tooltip: panel.label(context),
      isSelected: viewModel.selectedPanel == panel,
      // Selecting the open panel again closes it (see the bloc).
      onPressed: () => viewModel.onPanelSelected(panel),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxs,
      children: [
        if (capabilities.search) toggle(WorkspacePanel.search, Symbols.search),
        if (capabilities.bookmarks)
          toggle(WorkspacePanel.bookmarks, Symbols.bookmark),
        if (capabilities.comments)
          toggle(WorkspacePanel.comments, Symbols.comment),
        toggle(WorkspacePanel.dictionary, Symbols.dictionary),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
