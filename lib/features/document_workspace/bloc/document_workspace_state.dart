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
  });

  final int currentPage;
  final int pageCount;
  final double currentZoom;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;
  final SearchState searchState;
  final List<Bookmark> bookmarks;
  final List<Annotation> annotations;

  DocumentWorkspaceLoaded copyWith({
    int? currentPage,
    int? pageCount,
    double? currentZoom,
    WorkspaceTool? selectedTool,
    Object? selectedPanel = _unset,
    SearchState? searchState,
    List<Bookmark>? bookmarks,
    List<Annotation>? annotations,
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
    );
  }
}

final class DocumentWorkspaceError extends DocumentWorkspaceState {
  const DocumentWorkspaceError(this.message);

  final String message;
}

const _unset = Object();

class SearchState {
  const SearchState({
    this.query,
    this.results = const [],
    this.isLoading = false,
    this.currentIndex,
  });

  final String? query;
  final List<TextSearchResult> results;
  final bool isLoading;
  final int? currentIndex;

  SearchState copyWith({
    Object? query = _unset,
    List<TextSearchResult>? results,
    bool? isLoading,
    Object? currentIndex = _unset,
  }) {
    return SearchState(
      query: identical(query, _unset) ? this.query : query as String?,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: identical(currentIndex, _unset)
          ? this.currentIndex
          : currentIndex as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          listEquals(results, other.results) &&
          isLoading == other.isLoading &&
          currentIndex == other.currentIndex;

  @override
  int get hashCode =>
      Object.hash(query, Object.hashAll(results), isLoading, currentIndex);
}
