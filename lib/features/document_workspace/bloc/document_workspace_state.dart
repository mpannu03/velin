part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceState {
  const DocumentWorkspaceState();
}

final class DocumentWorkspaceInitial extends DocumentWorkspaceState {
  const DocumentWorkspaceInitial();
}

final class DocumentWorkspaceOpening extends DocumentWorkspaceState {
  const DocumentWorkspaceOpening({this.initialPageNumber});

  final int? initialPageNumber;
}

final class DocumentWorkspaceLoaded extends DocumentWorkspaceState {
  const DocumentWorkspaceLoaded({
    required this.currentPage,
    required this.pageCount,
    required this.currentZoom,
    this.selectedTool = WorkspaceTool.select,
    this.selectedPanel,
    this.searchState = const SearchState(),
    this.bookmarks = const [],
    this.annotations = const [],
    this.dictionaryState = const DictionaryState(),
  });

  final int currentPage;
  final int pageCount;
  final double currentZoom;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;
  final SearchState searchState;
  final List<Bookmark> bookmarks;
  final List<Annotation> annotations;
  final DictionaryState dictionaryState;

  DocumentWorkspaceLoaded copyWith({
    int? currentPage,
    int? pageCount,
    double? currentZoom,
    WorkspaceTool? selectedTool,
    Object? selectedPanel = _unset,
    SearchState? searchState,
    List<Bookmark>? bookmarks,
    List<Annotation>? annotations,
    DictionaryState? dictionaryState,
  }) {
    return DocumentWorkspaceLoaded(
      currentPage: currentPage ?? this.currentPage,
      pageCount: pageCount ?? this.pageCount,
      currentZoom: currentZoom ?? this.currentZoom,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedPanel: identical(selectedPanel, _unset)
          ? this.selectedPanel
          : selectedPanel as WorkspacePanel?,
      searchState: searchState ?? this.searchState,
      bookmarks: bookmarks ?? this.bookmarks,
      annotations: annotations ?? this.annotations,
      dictionaryState: dictionaryState ?? this.dictionaryState,
    );
  }
}

final class DocumentWorkspaceError extends DocumentWorkspaceState {
  const DocumentWorkspaceError(this.message);

  final String message;
}

const _unset = Object();
