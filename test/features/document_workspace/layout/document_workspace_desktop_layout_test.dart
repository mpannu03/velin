import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../helpers/helpers.dart';

void main() {
  late List<String> calls;

  setUp(() => calls = []);

  DocumentWorkspaceViewModel buildViewModel({
    int? currentPage = 5,
    int pageCount = 10,
    WorkspacePanel? selectedPanel,
    DocumentEngineCapabilities capabilities = const DocumentEngineCapabilities(
      search: true,
      bookmarks: true,
    ),
  }) {
    return DocumentWorkspaceViewModel(
      currentPage: currentPage,
      pageCount: pageCount,
      currentZoom: 1.25,
      documentViewer: const Text('Document Viewer'),
      selectedTool: WorkspaceTool.select,
      selectedPanel: selectedPanel,
      capabilities: capabilities,
      zoomIn: () => calls.add('zoomIn'),
      zoomOut: () => calls.add('zoomOut'),
      fitWidth: () => calls.add('fitWidth'),
      fitPage: () => calls.add('fitPage'),
      previousPage: () => calls.add('previousPage'),
      nextPage: () => calls.add('nextPage'),
      onToolSelected: (tool) => calls.add('tool:${tool.name}'),
      onPanelSelected: (panel) => calls.add('panel:${panel.name}'),
      onGotoPage: (page) => calls.add('goto:$page'),
      onPanelClosed: () => calls.add('panelClosed'),
      searchState: SearchState(
        results: const [],
        currentIndex: null,
        isLoading: false,
      ),
      onTextSearch: (_, _) {},
      onClearSearch: () {},
      onTextSearchResultSelected: (_) {},
      bookmarks: const [],
      onBookmarkSelected: (_) {},
      annotations: const [],
      onAnnotationSelected: (_) {},
      dictionaryState: DictionaryState(),
      onDictionaryLookup: (_) {},
      onClearDictionary: () {},
    );
  }

  Future<void> pumpLayout(
    WidgetTester tester,
    DocumentWorkspaceViewModel viewModel,
  ) async {
    await setViewSize(tester, const Size(1400, 900));
    addTearDown(() => resetViewSize(tester));
    await pumpApp(tester, DocumentWorkspaceDesktopLayout(viewModel: viewModel));
  }

  Future<void> tapTooltip(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  testWidgets('shows the toolbar and the page, without a panel', (
    tester,
  ) async {
    await pumpLayout(tester, buildViewModel());

    expect(find.text('Document Viewer'), findsOneWidget);
    expect(find.byType(DocumentWorkspaceToolbar), findsOneWidget);
    expect(find.byType(DocumentWorkspacePanel), findsNothing);
    expect(find.text('/ 10'), findsOneWidget);
    expect(find.text('125%'), findsOneWidget);
  });

  testWidgets('docks the selected panel on the right', (tester) async {
    await pumpLayout(
      tester,
      buildViewModel(selectedPanel: WorkspacePanel.bookmarks),
    );

    expect(find.byType(DocumentWorkspacePanel), findsOneWidget);
    expect(find.byType(BookmarkPanel), findsOneWidget);
  });

  testWidgets('the panel close button closes it', (tester) async {
    await pumpLayout(
      tester,
      buildViewModel(selectedPanel: WorkspacePanel.search),
    );

    await tapTooltip(tester, 'Close panel');

    expect(calls, ['panelClosed']);
  });

  testWidgets('toolbar buttons run their actions', (tester) async {
    await pumpLayout(tester, buildViewModel());

    for (final tooltip in [
      'Previous page',
      'Next page',
      'Zoom out',
      'Zoom in',
      'Fit width',
      'Fit page',
      'Search',
      'Bookmarks',
      'Dictionary',
    ]) {
      await tapTooltip(tester, tooltip);
    }

    expect(calls, [
      'previousPage',
      'nextPage',
      'zoomOut',
      'zoomIn',
      'fitWidth',
      'fitPage',
      'panel:search',
      'panel:bookmarks',
      'panel:dictionary',
    ]);
  });

  testWidgets('hides panel toggles the document does not support', (
    tester,
  ) async {
    await pumpLayout(
      tester,
      buildViewModel(capabilities: const DocumentEngineCapabilities()),
    );

    expect(find.byTooltip('Search'), findsNothing);
    expect(find.byTooltip('Bookmarks'), findsNothing);
    expect(find.byTooltip('Comments'), findsNothing);
  });

  testWidgets('disables previous on the first page and next on the last', (
    tester,
  ) async {
    await pumpLayout(tester, buildViewModel(currentPage: 1, pageCount: 1));

    await tapTooltip(tester, 'Previous page');
    await tapTooltip(tester, 'Next page');

    expect(calls, isEmpty);
  });
}
