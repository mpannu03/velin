import 'package:material_ui/material_ui.dart';
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
    required this.bookmarks,
    required this.onBookmarkSelected,
    required this.annotations,
    required this.onAnnotationSelected,
  });

  final WorkspacePanel panel;

  final SearchState searchState;
  final Function(String text, bool caseInsensitive) onTextSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<TextSearchResult> onTextSearchResultSelected;

  final List<Bookmark> bookmarks;
  final ValueChanged<Bookmark> onBookmarkSelected;

  final List<Annotation> annotations;
  final ValueChanged<Annotation> onAnnotationSelected;

  @override
  Widget build(BuildContext context) {
    return PanelShell(title: panel.label(context), child: panelBody);
  }

  Widget get panelBody => switch (panel) {
    WorkspacePanel.comments => CommentPanel(
      annotations: annotations,
      onAnnotationSelected: onAnnotationSelected,
    ),
    WorkspacePanel.bookmarks => BookmarkPanel(
      bookmarks: bookmarks,
      onBookmarkSelected: onBookmarkSelected,
    ),
    WorkspacePanel.search => SearchPanel(
      onTextSearch: onTextSearch,
      onClearSearch: onClearSearch,
      onTextSearchResultSelected: onTextSearchResultSelected,
      results: searchState.results,
      currentIndex: searchState.currentIndex,
      isLoading: searchState.isLoading,
    ),
    WorkspacePanel.dictionary => Text('Dictionary'),
  };
}
