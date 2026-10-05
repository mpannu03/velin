import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolsDesktopLayout', () {
    testWidgets('renders all tool categories by default', (tester) async {
      await pumpApp(tester, ToolsDesktopLayout(onToolTap: (_) {}));

      expect(
        find.byType(ToolCategorySection),
        findsNWidgets(ToolCategory.values.length),
      );
    });

    testWidgets('filters tools when a category is selected', (tester) async {
      await pumpApp(tester, ToolsDesktopLayout(onToolTap: (_) {}));

      final context = tester.element(find.byType(ToolsDesktopLayout));
      final filter = find.byType(ToolCategoryFilter);

      await tester.tap(
        find.descendant(
          of: filter,
          matching: find.text(context.l10n.toolsCategoryEdit),
        ),
      );
      await tester.pump();

      expect(find.byType(ToolCategorySection), findsOneWidget);

      final section = tester.widget<ToolCategorySection>(
        find.byType(ToolCategorySection),
      );

      expect(section.category, ToolCategory.edit);
    });

    testWidgets('restores all categories when All is selected', (tester) async {
      await pumpApp(tester, ToolsDesktopLayout(onToolTap: (_) {}));

      final context = tester.element(find.byType(ToolsDesktopLayout));
      final filter = find.byType(ToolCategoryFilter);

      await tester.tap(
        find.descendant(
          of: filter,
          matching: find.text(context.l10n.toolsCategoryEdit),
        ),
      );
      await tester.pump();

      expect(find.byType(ToolCategorySection), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: filter,
          matching: find.text(context.l10n.toolsCategoryAll),
        ),
      );
      await tester.pump();

      expect(
        find.byType(ToolCategorySection),
        findsNWidgets(ToolCategory.values.length),
      );
    });

    testWidgets('forwards the tapped tool', (tester) async {
      ToolDefinition? tappedTool;

      await pumpApp(
        tester,
        ToolsDesktopLayout(onToolTap: (tool) => tappedTool = tool),
      );

      final context = tester.element(find.byType(ToolsDesktopLayout));
      final tool = ToolRegistry.mergePdf;

      await tester.tap(find.text(tool.title(context)));
      await tester.pump();

      expect(tappedTool, same(tool));
    });
  });
}
