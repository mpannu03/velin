import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';
import 'package:velin/features/reader/layout/reader_desktop_layout.dart';
import 'package:velin/features/reader/view/reader_view_model.dart';
import 'package:velin/features/reader/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

class MockDocumentWorkspaceBloc
    extends MockBloc<DocumentWorkspaceEvent, DocumentWorkspaceState>
    implements DocumentWorkspaceBloc {}

class MockDocumentEngineFactory extends Mock implements DocumentEngineFactory {}

class MockDocumentEngine extends Mock implements DocumentEngine {}

void main() {
  final getIt = GetIt.instance;

  group('ReaderDesktopLayout', () {
    late Document firstDocument;
    late Document secondDocument;

    late MockDocumentWorkspaceBloc bloc;
    late MockDocumentEngineFactory engineFactory;
    late MockDocumentEngine engine;

    setUpAll(() {
      registerFallbackValue(Document(path: '', type: DocumentType.pdf));
      registerFallbackValue(DocumentEngineConfig());
    });

    setUp(() {
      bloc = MockDocumentWorkspaceBloc();
      engineFactory = MockDocumentEngineFactory();
      engine = MockDocumentEngine();

      when(() => bloc.state).thenReturn(const DocumentWorkspaceInitial());

      when(() => engineFactory.create(any())).thenReturn(engine);

      when(() => engine.buildViewer(config: any(named: 'config')))
          .thenReturn(Text('Sample Content'));

      getIt.registerLazySingleton<DocumentEngineFactory>(() => engineFactory);

      getIt.registerFactoryParam<DocumentWorkspaceBloc, DocumentEngine, void>(
        (engine, _) => bloc,
      );

      firstDocument = Document(
        path: r'C:\Documents\first.pdf',
        type: DocumentType.pdf,
      );

      secondDocument = Document(
        path: r'C:\Documents\second.pdf',
        type: DocumentType.pdf,
      );
    });

    tearDown(() {
      getIt.reset();
    });

    testWidgets('shows document tabs and selected document workspace', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [firstDocument, secondDocument],
        selectedDocument: firstDocument,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(tester, ReaderDesktopLayout(viewModel: viewModel));

      expect(find.byType(ReaderDocumentTabs), findsOneWidget);
      expect(find.byType(DocumentWorkspacePage), findsOneWidget);
    });

    testWidgets('shows empty state when no document is selected', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [firstDocument],
        selectedDocument: null,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(tester, ReaderDesktopLayout(viewModel: viewModel));

      expect(find.byType(ReaderEmptyState), findsOneWidget);
      expect(find.byType(DocumentWorkspacePage), findsNothing);
    });

    testWidgets('passes documents and selected document to tabs', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [firstDocument, secondDocument],
        selectedDocument: secondDocument,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(tester, ReaderDesktopLayout(viewModel: viewModel));

      final tabs = tester.widget<ReaderDocumentTabs>(
        find.byType(ReaderDocumentTabs),
      );

      expect(tabs.documents, same(viewModel.documents));
      expect(tabs.selectedDocument, same(secondDocument));
    });
  });
}
