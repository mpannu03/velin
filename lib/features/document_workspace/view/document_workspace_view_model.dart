import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';

import '../bloc/bloc.dart';
import '../models/models.dart';

class DocumentWorkspaceViewModel {
  const DocumentWorkspaceViewModel({
    required this.currentPage,
    required this.pageCount,
    required this.currentZoom,
    required this.documentViewer,
    required this.selectedTool,
    required this.selectedPanel,
    required this.capabilities,
    required this.zoomIn,
    required this.zoomOut,
    required this.onToolSelected,
    required this.onPanelSelected,
    required this.onGotoPage,
    required this.onPanelClosed,
    required this.searchState,
    required this.onTextSearch,
    required this.onClearSearch,
    required this.onTextSearchResultSelected,
    required this.bookmarks,
    required this.onBookmarkSelected,
    required this.annotations,
    required this.onAnnotationSelected,
  });

  final int? currentPage;
  final int pageCount;
  final double currentZoom;
  final Widget documentViewer;

  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;

  final DocumentEngineCapabilities capabilities;

  final VoidCallback zoomIn;
  final VoidCallback zoomOut;

  final ValueChanged<WorkspaceTool> onToolSelected;
  final ValueChanged<WorkspacePanel> onPanelSelected;
  final ValueChanged<int> onGotoPage;
  final VoidCallback onPanelClosed;

  final SearchState searchState;
  final Function(String text, bool caseInsensitive) onTextSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<TextSearchResult> onTextSearchResultSelected;

  final List<Bookmark> bookmarks;
  final ValueChanged<Bookmark> onBookmarkSelected;

  final List<Annotation> annotations;
  final ValueChanged<Annotation> onAnnotationSelected;
}