part of 'document_workspace_bloc.dart';

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
