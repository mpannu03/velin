import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/bloc/document_workspace_bloc.dart';

class MockDocumentEngine extends Mock implements DocumentEngine {}

class MockTextSearchCapability extends Mock implements TextSearchCapability {}

void main() {
  late MockDocumentEngine engine;
  late MockTextSearchCapability textSearch;
  late TextSearchResult result;

  setUp(() {
    engine = MockDocumentEngine();
    textSearch = MockTextSearchCapability();
    result = const TextSearchResult(
      index: 0,
      pageNumber: 1,
      text: 'needle',
    );

    when(() => engine.capabilities).thenReturn(
      const DocumentEngineCapabilities(textSelection: true),
    );
    when(() => engine.textSearch).thenReturn(textSearch);
  });

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'searches once and stores the returned results',
    setUp: () {
      when(() => textSearch.search('needle')).thenAnswer(
        (_) => Stream.value([result]),
      );
    },
    build: () => DocumentWorkspaceBloc(engine: engine),
    seed: () => const DocumentWorkspaceLoaded(pageCount: 1, currentZoom: 1),
    act: (bloc) => bloc.add(const DocumentWorkspaceSearch('needle')),
    expect: () => [
      isA<DocumentWorkspaceLoaded>()
          .having((state) => state.searchState.results, 'results', [result])
          .having((state) => state.searchState.isLoading, 'isLoading', false),
    ],
    verify: (_) => verify(() => textSearch.search('needle')).called(1),
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'forwards a selected result to the search capability',
    setUp: () {
      when(() => textSearch.selectResult(result)).thenAnswer((_) async {});
    },
    build: () => DocumentWorkspaceBloc(engine: engine),
    seed: () => DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      searchState: SearchState(results: [result]),
    ),
    act: (bloc) => bloc.add(DocumentWorkspaceSelectSearch(result)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.searchState.currentIndex,
        'currentIndex',
        result.index,
      ),
    ],
    verify: (_) => verify(() => textSearch.selectResult(result)).called(1),
  );
}