part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceState {
  const DocumentWorkspaceState();
}

final class DocumentWorkspaceInitial extends DocumentWorkspaceState {
  const DocumentWorkspaceInitial();
}

final class DocumentWorkspaceLoading extends DocumentWorkspaceState {
  const DocumentWorkspaceLoading();
}

final class DocumentWorkspaceLoaded extends DocumentWorkspaceState {
  const DocumentWorkspaceLoaded({
    required this.pageCount,
    this.currentPage,
    this.selectedTool = WorkspaceTool.select,
    this.selectedPanel,
    required this.currentZoom,
    this.searchState = const SearchState(),
    this.bookmarks = const [],
  });

  final int? currentPage;
  final int pageCount;
  final double currentZoom;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;
  final SearchState searchState;
  final List<Bookmark> bookmarks;

  DocumentWorkspaceLoaded copyWith({
    Object? currentPage = _unset,
    int? pageCount,
    double? currentZoom,
    WorkspaceTool? selectedTool,
    Object? selectedPanel = _unset,
    SearchState? searchState,
    List<Bookmark>? bookmarks ,
  }) {
    return DocumentWorkspaceLoaded(
      currentPage: identical(currentPage, _unset)
          ? this.currentPage
          : currentPage as int?,
      pageCount: pageCount ?? this.pageCount,
      currentZoom: currentZoom ?? this.currentZoom,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedPanel: identical(selectedPanel, _unset)
          ? this.selectedPanel
          : selectedPanel as WorkspacePanel?,
      searchState: searchState ?? this.searchState,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

final class DocumentWorkspaceError extends DocumentWorkspaceState {
  const DocumentWorkspaceError(this.message);

  final String message;
}

const _unset = Object();

class SearchState {
  final String? query;
  final List<TextSearchResult> results;
  final bool isLoading;
  final int? currentIndex;

  const SearchState({
    this.query,
    this.results = const [],
    this.isLoading = false,
    this.currentIndex,
  });

  SearchState copyWith({
    Object? query = _unset,
    List<TextSearchResult>? results,
    bool? isLoading,
    Object? currentIndex = _unset,
  }) {
    return SearchState(
      query: identical(query, _unset) 
          ? this.query : query as String?,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: identical(currentIndex, _unset) 
          ? this.currentIndex : currentIndex as int?,
    );
  }
}
