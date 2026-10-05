import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../helpers/helpers.dart';

class MockDocumentEngineFactory extends Mock implements DocumentEngineFactory {}

class MockDocumentEngine extends Mock implements DocumentEngine {}

class MockDocumentEngineActions extends Mock implements DocumentEngineActions {}

class MockDocumentWorkspaceBloc
    extends MockBloc<DocumentWorkspaceEvent, DocumentWorkspaceState>
    implements DocumentWorkspaceBloc {}

class FakeDocument extends Fake implements Document {}

void main() {
  late MockDocumentEngineFactory engineFactory;
  late MockDocumentEngine engine;
  late MockDocumentEngineActions actions;
  late MockDocumentWorkspaceBloc bloc;
  late Document document;

  setUpAll(() {
    registerFallbackValue(FakeDocument());
    registerFallbackValue(DocumentEngineConfig());
    registerFallbackValue(DocumentWorkspaceStarted());
  });

  setUp(() {
    engineFactory = MockDocumentEngineFactory();
    engine = MockDocumentEngine();
    actions = MockDocumentEngineActions();
    bloc = MockDocumentWorkspaceBloc();
    document = FakeDocument();

    getIt.reset();

    getIt.registerSingleton<DocumentEngineFactory>(engineFactory);

    getIt.registerFactoryParam<DocumentWorkspaceBloc, DocumentEngine, void>(
      (engine, _) => bloc,
    );

    when(() => engineFactory.create(document)).thenReturn(engine);
    when(() => engine.capabilities)
        .thenReturn(const DocumentEngineCapabilities());
    when(() => engine.actions).thenReturn(actions);
    when(() => engine.buildViewer(config: any(named: 'config')))
        .thenReturn(const Text('Document Viewer'));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows loading indicator while workspace is loading', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const DocumentWorkspaceLoading());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    await pumpApp(tester, DocumentWorkspacePage(document: document));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verify(() => bloc.add(any(that: isA<DocumentWorkspaceStarted>())))
        .called(1);
  });

  testWidgets('shows error message when workspace fails', (tester) async {
    when(() => bloc.state)
        .thenReturn(const DocumentWorkspaceError('Something went wrong'));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    await pumpApp(tester, DocumentWorkspacePage(document: document));

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('shows workspace view when loaded', (tester) async {
    when(() => bloc.state).thenReturn(
      DocumentWorkspaceLoaded(
        currentPage: 1,
        pageCount: 10,
        currentZoom: 1,
        selectedTool: WorkspaceTool.select,
        selectedPanel: null,
        searchState: SearchState(),
        bookmarks: const [],
        annotations: const [],
      ),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => engine.buildViewer(config: any(named: 'config')))
        .thenReturn(const Text('Document Viewer'));

    await pumpApp(tester, DocumentWorkspacePage(document: document));

    expect(find.byType(DocumentWorkspaceView), findsOneWidget);
  });
}
