import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolCategorySection', () {
    testWidgets('renders nothing when tools are empty', (tester) async {
      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: const [],
          onToolTap: _noop,
        ),
      );

      expect(find.byType(ToolCategorySection), findsOneWidget);
      expect(find.byType(ToolCard), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders category label and tool count', (tester) async {
      final tools = [
        _createTool(ToolId.mergePdf),
        _createTool(ToolId.splitPdf),
        _createTool(ToolId.rotatePdf),
      ];

      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: tools,
          onToolTap: _noop,
        ),
      );

      final context = tester.element(find.byType(ToolCategorySection));

      expect(find.text(ToolCategory.edit.label(context)), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders one ToolCard for each tool', (tester) async {
      final tools = [
        _createTool(ToolId.mergePdf),
        _createTool(ToolId.splitPdf),
        _createTool(ToolId.rotatePdf),
      ];

      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: tools,
          onToolTap: _noop,
        ),
      );

      expect(find.byType(ToolCard), findsNWidgets(tools.length));
    });

    testWidgets('renders each tool in the section', (tester) async {
      final tools = [
        _createTool(ToolId.mergePdf),
        _createTool(ToolId.splitPdf),
      ];

      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: tools,
          onToolTap: _noop,
        ),
      );

      final sectionContext = tester.element(find.byType(ToolCategorySection));

      for (final tool in tools) {
        final title = tool.title(sectionContext);

        expect(find.widgetWithText(ToolCard, title), findsOneWidget);
      }
    });

    testWidgets('forwards the tapped tool to onToolTap', (tester) async {
      final firstTool = _createTool(ToolId.mergePdf);
      final secondTool = _createTool(ToolId.splitPdf);

      ToolDefinition? tappedTool;

      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: [firstTool, secondTool],
          onToolTap: (tool) => tappedTool = tool,
        ),
      );

      final cards = find.byType(ToolCard);

      await tester.tap(cards.at(1));
      await tester.pump();

      expect(tappedTool, same(secondTool));
    });

    testWidgets('renders the correct number of cards for a single tool', (
      tester,
    ) async {
      final tool = _createTool(ToolId.mergePdf);

      await pumpApp(
        tester,
        ToolCategorySection(
          category: ToolCategory.edit,
          tools: [tool],
          onToolTap: _noop,
        ),
      );

      expect(find.byType(ToolCard), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}

ToolDefinition _createTool(ToolId id) {
  return ToolDefinition(
    id: id,
    category: ToolCategory.edit,
    icon: Icons.picture_as_pdf,
    route: '/tools/$id',
  );
}

void _noop(ToolDefinition tool) {}
