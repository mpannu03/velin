import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolCard', () {
    testWidgets('renders tool title and description', (tester) async {
      final tool = _createTool();

      await pumpApp(tester, ToolCard(tool: tool, onTap: _noop));

      expect(find.text('Merge PDF'), findsOneWidget);
      expect(
        find.text('Combine multiple PDF files into one document.'),
        findsOneWidget,
      );
    });

    testWidgets('renders tool icon', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      expect(find.byIcon(Icons.merge_type), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        ToolCard(tool: _createTool(), onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows arrow when hovered', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      final opacityFinder = find.descendant(
        of: find.byType(ToolCard),
        matching: find.byType(AnimatedOpacity),
      );

      expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, 0);

      final mouseRegionFinder = find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion && widget.cursor == SystemMouseCursors.click,
      );

      expect(mouseRegionFinder, findsOneWidget);

      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);

      mouseRegion.onEnter?.call(const PointerEnterEvent());
      await tester.pump();

      expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, 1);
    });

    testWidgets('hides arrow when hover ends', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      final mouseRegion = tester.widget<MouseRegion>(
        find.byWidgetPredicate(
          (widget) =>
              widget is MouseRegion &&
              widget.cursor == SystemMouseCursors.click,
        ),
      );

      mouseRegion.onEnter?.call(const PointerEnterEvent());
      await tester.pump();

      mouseRegion.onExit?.call(const PointerExitEvent());
      await tester.pump();

      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(ToolCard),
          matching: find.byType(AnimatedOpacity),
        ),
      );

      expect(opacity.opacity, 0);
    });

    testWidgets('changes icon chip when hovered', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      final containerFinder = find.descendant(
        of: find.byType(ToolCard),
        matching: find.byType(AnimatedContainer),
      );

      final initialContainer = tester.widget<AnimatedContainer>(
        containerFinder,
      );

      final initialDecoration = initialContainer.decoration! as BoxDecoration;

      final mouseRegion = tester.widget<MouseRegion>(
        find.byWidgetPredicate(
          (widget) =>
              widget is MouseRegion &&
              widget.cursor == SystemMouseCursors.click,
        ),
      );

      mouseRegion.onEnter?.call(const PointerEnterEvent());
      await tester.pump();

      final hoveredContainer = tester.widget<AnimatedContainer>(
        containerFinder,
      );

      final hoveredDecoration = hoveredContainer.decoration! as BoxDecoration;

      expect(hoveredDecoration.color, isNot(equals(initialDecoration.color)));
    });

    testWidgets('uses click cursor for mouse interaction', (tester) async {
      await pumpApp(tester, ToolCard(tool: _createTool(), onTap: _noop));

      final mouseRegionFinder = find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion && widget.cursor == SystemMouseCursors.click,
      );

      expect(mouseRegionFinder, findsOneWidget);
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
