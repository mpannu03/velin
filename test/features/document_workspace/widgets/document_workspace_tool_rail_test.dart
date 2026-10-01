import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('DocumentWorkspaceToolRail', () {
    testWidgets('renders select tool', (tester) async {
      await pumpApp(
        tester,
        DocumentWorkspaceToolRail(
          selectedTool: WorkspaceTool.select,
          capabilities: const DocumentEngineCapabilities(),
          onToolSelected: (_) {},
        ),
      );

      expect(
        find.byTooltip('Select'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders dictionary tool when text selection is supported',
      (tester) async {
        await pumpApp(
          tester,
          DocumentWorkspaceToolRail(
            selectedTool: WorkspaceTool.dictionary,
            capabilities: const DocumentEngineCapabilities(
              textSelection: true,
            ),
            onToolSelected: (_) {},
          ),
        );

        expect(
          find.byTooltip('Dictionary'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does not render dictionary tool when text selection is unsupported',
      (tester) async {
        await pumpApp(
          tester,
          DocumentWorkspaceToolRail(
            selectedTool: WorkspaceTool.select,
            capabilities: const DocumentEngineCapabilities(),
            onToolSelected: (_) {},
          ),
        );

        expect(
          find.byTooltip('Dictionary'),
          findsNothing,
        );
      },
    );

    testWidgets('selects tool when select button is tapped', (
      tester,
    ) async {
      WorkspaceTool? selectedTool;

      await pumpApp(
        tester,
        DocumentWorkspaceToolRail(
          selectedTool: WorkspaceTool.dictionary,
          capabilities: const DocumentEngineCapabilities(),
          onToolSelected: (tool) => selectedTool = tool,
        ),
      );

      await tester.tap(find.byTooltip('Select'));

      expect(selectedTool, WorkspaceTool.select);
    });

    testWidgets('selects tool when dictionary button is tapped', (
      tester,
    ) async {
      WorkspaceTool? selectedTool;

      await pumpApp(
        tester,
        DocumentWorkspaceToolRail(
          selectedTool: WorkspaceTool.select,
          capabilities: const DocumentEngineCapabilities(
            textSelection: true,
          ),
          onToolSelected: (tool) => selectedTool = tool,
        ),
      );

      await tester.tap(find.byTooltip('Dictionary'));

      expect(selectedTool, WorkspaceTool.dictionary);
    });
  });
}