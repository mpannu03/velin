import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolCard', () {
    testWidgets('renders tool icon, title and description', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      expect(find.text('Merge PDF'), findsOneWidget);
      expect(
        find.text('Combine multiple PDF files into one document.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.merge_type), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        ToolCard(tool: _createTool(), onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('highlights on hover', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      Color? cardColor() => tester
          .widget<Material>(
            find
                .descendant(
                  of: find.byType(ToolCard),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color;

      final initial = cardColor();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byType(ToolCard)));
      await tester.pumpAndSettle();

      expect(cardColor(), isNot(initial));
    });
  });
}

ToolDefinition _createTool() {
  return ToolDefinition(
    id: ToolId.mergePdf,
    category: ToolCategory.edit,
    icon: Icons.merge_type,
    route: '/tools/merge-pdf',
  );
}

void _noop() {}
