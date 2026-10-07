import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/recent/recent_document_service.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';
import 'package:velin/services/dictionary/dictionary.dart';

class MockDocumentEngine extends Mock implements DocumentEngine {}

class MockTextSearchCapability extends Mock implements TextSearchCapability {}

class MockRecentDocumentService extends Mock implements RecentDocumentService {}

class MockDictionaryService extends Mock implements DictionaryService {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late MockDocumentEngine engine;
  late MockTextSearchCapability textSearch;
  late MockRecentDocumentService recentDocumentService;
  late MockAppEffectController appEffectController;
  late MockDictionaryService dictionaryService;
  late TextSearchResult result;

  DocumentWorkspaceBloc buildBloc() {
    return DocumentWorkspaceBloc(
      engine: engine,
      recentDocumentService: recentDocumentService,
      appEffectController: appEffectController,
      dictionaryService: dictionaryService,
    );
  }

  setUpAll(() {
    registerFallbackValue(const Duration());
    registerFallbackValue(DocumentType.pdf);
  });

  setUp(() {
    engine = MockDocumentEngine();
    textSearch = MockTextSearchCapability();
    recentDocumentService = MockRecentDocumentService();
    appEffectController = MockAppEffectController();
    dictionaryService = MockDictionaryService();

    result = const TextSearchResult(index: 0, pageNumber: 1, text: 'needle');

    when(() => engine.document)
        .thenReturn(Document(path: '/test/path.pdf', type: DocumentType.pdf));

    when(() => engine.snapshot).thenReturn(
      const DocumentEngineSnapshot(currentPage: 0, pageCount: 0, zoom: 1.0),
    );

    when(() => engine.capabilities)
        .thenReturn(const DocumentEngineCapabilities(textSelection: true));

    when(() => engine.textSearch).thenReturn(textSearch);

    when(() => recentDocumentService.get(any()))
        .thenAnswer((_) async => const Failure('not found'));

    when(
      () => recentDocumentService.open(
        path: any(named: 'path'),
        pageCount: any(named: 'pageCount'),
        currentPage: any(named: 'currentPage'),
        documentType: any(named: 'documentType'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => recentDocumentService.pageChanged(
        path: any(named: 'path'),
        currentPage: any(named: 'currentPage'),
      ),
    ).thenAnswer((_) async {});

    when(() => recentDocumentService.flush(any())).thenAnswer((_) async {});
  });

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'starts with an empty loaded workspace',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const DocumentWorkspaceStarted()),
    expect: () => [isA<DocumentWorkspaceOpening>()],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'becomes loaded when ready',
    build: buildBloc,
    seed: () => const DocumentWorkspaceOpening(initialPageNumber: 1),
    act: (bloc) => bloc.add(const DocumentWorkspaceReady()),
    expect: () => [
      isA<DocumentWorkspaceLoaded>()
          .having((state) => state.currentPage, 'currentPage', 0)
          .having((state) => state.pageCount, 'pageCount', 0)
          .having((state) => state.currentZoom, 'currentZoom', 1.0),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'updates current page',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 10,
      currentPage: 1,
      currentZoom: 1,
    ),
    act: (bloc) => bloc.add(const DocumentWorkspacePageChanged(5)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.currentPage,
        'currentPage',
        5,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'does not update current page when page changes to null',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 10,
      currentPage: 5,
      currentZoom: 1,
    ),
    act: (bloc) => bloc.add(const DocumentWorkspacePageChanged(null)),
    expect: () => [],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'updates current zoom',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 10,
      currentZoom: 1,
      currentPage: 1,
    ),
    act: (bloc) => bloc.add(const DocumentWorkspaceZoomChanged(1.5)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.currentZoom,
        'currentZoom',
        1.5,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'selects a tool',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
    ),
    act: (bloc) =>
        bloc.add(const DocumentWorkspaceToolSelected(WorkspaceTool.dictionary)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.selectedTool,
        'selectedTool',
        WorkspaceTool.dictionary,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'selects a panel',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
    ),
    act: (bloc) =>
        bloc.add(const DocumentWorkspacePanelSelected(WorkspacePanel.search)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.selectedPanel,
        'selectedPanel',
        WorkspacePanel.search,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'closes panel when selecting the already selected panel',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
      selectedPanel: WorkspacePanel.search,
    ),
    act: (bloc) =>
        bloc.add(const DocumentWorkspacePanelSelected(WorkspacePanel.search)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.selectedPanel,
        'selectedPanel',
        null,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'closes selected panel',
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
      selectedPanel: WorkspacePanel.bookmarks,
    ),
    act: (bloc) => bloc.add(const DocumentWorkspacePanelClosed()),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.selectedPanel,
        'selectedPanel',
        null,
      ),
    ],
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'searches once and stores the returned results',
    setUp: () {
      when(() => textSearch.search('needle', false))
          .thenAnswer((_) => Stream.value([result]));
    },
    build: buildBloc,
    seed: () => const DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
    ),
    act: (bloc) => bloc.add(const DocumentWorkspaceSearch('needle', false)),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.searchState.isLoading,
        'isLoading',
        true,
      ),
      isA<DocumentWorkspaceLoaded>()
          .having((state) => state.searchState.results, 'results', [result])
          .having((state) => state.searchState.isLoading, 'isLoading', false),
    ],
    verify: (_) => verify(() => textSearch.search('needle', false)).called(1),
  );

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'forwards a selected result to the search capability',
    setUp: () {
      when(() => textSearch.selectResult(result)).thenAnswer((_) async {});
    },
    build: buildBloc,
    seed: () => DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
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

  blocTest<DocumentWorkspaceBloc, DocumentWorkspaceState>(
    'clears search',
    setUp: () {
      when(() => textSearch.clear()).thenAnswer((_) async {});
    },
    build: buildBloc,
    seed: () => DocumentWorkspaceLoaded(
      pageCount: 1,
      currentZoom: 1,
      currentPage: 1,
      searchState: SearchState(
        query: 'needle',
        results: [result],
        currentIndex: 0,
      ),
    ),
    act: (bloc) => bloc.add(const DocumentWorkspaceClearSearch()),
    expect: () => [
      isA<DocumentWorkspaceLoaded>().having(
        (state) => state.searchState,
        'searchState',
        const SearchState(),
      ),
    ],
    verify: (_) {
      verify(() => textSearch.clear()).called(1);
    },
  );
}
