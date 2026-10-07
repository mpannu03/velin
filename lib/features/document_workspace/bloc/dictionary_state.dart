part of 'document_workspace_bloc.dart';

class DictionaryState {
  const DictionaryState({this.query, this.result, this.isLoading = false});

  final String? query;
  final DictionaryEntry? result;
  final bool isLoading;

  DictionaryState copyWith({Object? query, Object? result, bool? isLoading}) {
    return DictionaryState(
      query: identical(query, _unset) ? this.query : query as String?,
      result: identical(result, _unset)
          ? this.result
          : result as DictionaryEntry?,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(covariant DictionaryState other) {
    if (identical(this, other)) return true;

    return other.query == query &&
        other.result == result &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => query.hashCode ^ result.hashCode ^ isLoading.hashCode;
}
