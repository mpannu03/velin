import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../helpers/helpers.dart';

void main() {
  late DocumentWorkspaceViewModel viewModel;

  setUp(() {
    viewModel = DocumentWorkspaceViewModel(
      currentPage: 1,
      pageCount: 10,
      currentZoom: 1,
      documentViewer: const Text('Document Viewer'),
      selectedTool: WorkspaceTool.select,
      selectedPanel: null,
      capabilities: const DocumentEngineCapabilities(),
      zoomIn: () {},
      zoomOut: () {},
      onToolSelected: (_) {},
      onPanelSelected: (_) {},
      onGotoPage: (_) {},
      onPanelClosed: () {},
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
    );
  });

  testWidgets('renders document viewer and tool rail without selected panel', (
    tester,
  ) async {
    await pumpApp(tester, DocumentWorkspaceDesktopLayout(viewModel: viewModel));

    expect(find.text('Document Viewer'), findsOneWidget);
    expect(find.byType(DocumentWorkspaceToolRail), findsOneWidget);
    expect(find.byType(DocumentWorkspacePanelRail), findsOneWidget);
    expect(find.byType(DocumentWorkspacePanel), findsNothing);
  });

  testWidgets('renders selected panel', (tester) async {
    final updatedViewModel = DocumentWorkspaceViewModel(
      currentPage: viewModel.currentPage,
      pageCount: viewModel.pageCount,
      currentZoom: viewModel.currentZoom,
      documentViewer: viewModel.documentViewer,
      selectedTool: viewModel.selectedTool,
      selectedPanel: WorkspacePanel.bookmarks,
      capabilities: viewModel.capabilities,
      zoomIn: viewModel.zoomIn,
      zoomOut: viewModel.zoomOut,
      onToolSelected: viewModel.onToolSelected,
      onPanelSelected: viewModel.onPanelSelected,
      onGotoPage: viewModel.onGotoPage,
      onPanelClosed: viewModel.onPanelClosed,
      searchState: viewModel.searchState,
      onTextSearch: viewModel.onTextSearch,
      onClearSearch: viewModel.onClearSearch,
      onTextSearchResultSelected: viewModel.onTextSearchResultSelected,
      bookmarks: viewModel.bookmarks,
      onBookmarkSelected: viewModel.onBookmarkSelected,
      annotations: viewModel.annotations,
      onAnnotationSelected: viewModel.onAnnotationSelected,
    );

    await pumpApp(
      tester,
      DocumentWorkspaceDesktopLayout(viewModel: updatedViewModel),
    );

    expect(find.byType(DocumentWorkspacePanel), findsOneWidget);
    expect(find.byType(BookmarkPanel), findsOneWidget);
  });
}
