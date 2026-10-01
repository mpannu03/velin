import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DocumentWorkspacePanelRail', () {
    testWidgets('hides optional panels when capabilities are disabled', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SizedBox(
          height: 600,
          child: DocumentWorkspacePanelRail(
            selectedPanel: null,
            capabilities: const DocumentEngineCapabilities(),
            currentPage: 1,
            pageCount: 10,
            currentZoom: 1,
            zoomIn: () {},
            zoomOut: () {},
            onPanelSelected: (_) {},
            onGotoPage: (_) {},
          ),
        ),
      );

      expect(find.byTooltip('Comments'), findsNothing);
      expect(find.byTooltip('Bookmarks'), findsNothing);
      expect(find.byTooltip('Search'), findsNothing);
      expect(find.byTooltip('Dictionary'), findsOneWidget);
    });

    testWidgets('shows optional panels when capabilities are enabled', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SizedBox(
          height: 600,
          child: DocumentWorkspacePanelRail(
            selectedPanel: null,
            capabilities: const DocumentEngineCapabilities(
              comments: true,
              bookmarks: true,
              search: true,
            ),
            currentPage: 1,
            pageCount: 10,
            currentZoom: 1,
            zoomIn: () {},
            zoomOut: () {},
            onPanelSelected: (_) {},
            onGotoPage: (_) {},
          ),
        ),
      );

      expect(find.byTooltip('Comments'), findsOneWidget);
      expect(find.byTooltip('Bookmarks'), findsOneWidget);
      expect(find.byTooltip('Search'), findsOneWidget);
    });

    testWidgets('selects dictionary panel when tapped', (tester) async {
      WorkspacePanel? selectedPanel;

      await pumpApp(
        tester,
        SizedBox(
          height: 600,
          child: DocumentWorkspacePanelRail(
            selectedPanel: null,
            capabilities: const DocumentEngineCapabilities(),
            currentPage: 1,
            pageCount: 10,
            currentZoom: 1,
            zoomIn: () {},
            zoomOut: () {},
            onPanelSelected: (panel) => selectedPanel = panel,
            onGotoPage: (_) {},
          ),
        ),
      );

      await tester.tap(find.byTooltip('Dictionary'));

      expect(selectedPanel, WorkspacePanel.dictionary);
    });

    testWidgets('calls zoom callbacks', (tester) async {
      var zoomInCalled = false;
      var zoomOutCalled = false;

      await pumpApp(
        tester,
        SizedBox(
          height: 600,
          child: DocumentWorkspacePanelRail(
            selectedPanel: null,
            capabilities: const DocumentEngineCapabilities(),
            currentPage: 1,
            pageCount: 10,
            currentZoom: 1,
            zoomIn: () => zoomInCalled = true,
            zoomOut: () => zoomOutCalled = true,
            onPanelSelected: (_) {},
            onGotoPage: (_) {},
          ),
        ),
      );

      await tester.tap(find.byTooltip('Zoom In'));
      await tester.tap(find.byTooltip('Zoom Out'));

      expect(zoomInCalled, isTrue);
      expect(zoomOutCalled, isTrue);
    });
  });
}