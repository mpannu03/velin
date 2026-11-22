import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolsDesktopLayout', () {
    Future<void> pumpLayout(
      WidgetTester tester, {
      ValueChanged<ToolDefinition>? onToolTap,
    }) async {
      await setViewSize(tester, const Size(1400, 1000));
      addTearDown(() => resetViewSize(tester));
      await pumpApp(tester, ToolsDesktopLayout(onToolTap: onToolTap ?? (_) {}));
    }

    testWidgets('renders all tool categories by default', (tester) async {
      await pumpLayout(tester);

      expect(
        find.byType(ToolCategorySection),
        findsNWidgets(ToolCategory.values.length),
      );
      expect(find.byType(ToolCard), findsNWidgets(ToolRegistry.all.length));
    });

    testWidgets('search narrows the list to matching tools', (tester) async {
      await pumpLayout(tester);

      await tester.enterText(find.byType(TextField), 'merge');
      await tester.pump();

      final context = tester.element(find.byType(ToolsDesktopLayout));
      expect(find.byType(ToolCard), findsOneWidget);
      expect(find.text(ToolRegistry.mergePdf.title(context)), findsOneWidget);
      expect(find.byType(ToolCategorySection), findsOneWidget);
    });

    testWidgets('search without matches says so', (tester) async {
      await pumpLayout(tester);

      await tester.enterText(find.byType(TextField), 'nothing-like-this');
      await tester.pump();

      expect(find.byType(ToolCard), findsNothing);
      expect(find.text('No tools match "nothing-like-this".'), findsOneWidget);
    });

    testWidgets('forwards the tapped tool', (tester) async {
      ToolDefinition? tappedTool;

      await pumpLayout(tester, onToolTap: (tool) => tappedTool = tool);

      final context = tester.element(find.byType(ToolsDesktopLayout));
      final tool = ToolRegistry.mergePdf;

      await tester.tap(find.text(tool.title(context)));
      await tester.pump();

      expect(tappedTool, same(tool));
    });
  });
}
