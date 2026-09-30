import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/document/engine/engine.dart';

import '../../bloc/bloc.dart';
import '../../models/models.dart';
import 'panel.dart';

class DocumentWorkspacePanel extends StatelessWidget {
  const DocumentWorkspacePanel({
    super.key,
    required this.panel,
    required this.searchState,
    required this.onTextSearch,
    required this.onClearSearch,
    required this.onTextSearchResultSelected,
  });

  final WorkspacePanel panel;

  final SearchState searchState;
  final Function(String text) onTextSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<TextSearchResult> onTextSearchResultSelected;

  @override
  Widget build(BuildContext context) {
    return PanelShell(
      title: panel.label,
      trailing: trailing,
      child: panelBody,
    );
  }

  Widget get panelBody => switch (panel) {
        WorkspacePanel.comments => Text('Comments'),
        WorkspacePanel.bookmarks => Text('Bookmarks'),
        WorkspacePanel.search => SearchPanel(
          onTextSearch: onTextSearch,
          onClearSearch: onClearSearch,
          onTextSearchResultSelected: onTextSearchResultSelected,
          results: searchState.results,
          currentIndex: searchState.currentIndex,
          isLoading: searchState.isLoading,
        ),
      };
  
  Widget? get trailing => switch (panel) {
        WorkspacePanel.comments => null,
        WorkspacePanel.bookmarks => null,
        WorkspacePanel.search => _clearButton(() {}),
      };
}

Widget _clearButton(VoidCallback onPressed) {
  return IconButton(
    onPressed: () => onPressed(),
    icon: const Icon(Icons.clear, size: 16),
    padding: EdgeInsets.all(AppSpacing.xs),
    style: IconButton.styleFrom(
      minimumSize: Size.zero,
    ),
  );
}