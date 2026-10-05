import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolCategoryFilter', () {
    testWidgets('renders All and every tool category', (tester) async {
      await pumpApp(
        tester,
        ToolCategoryFilter(selected: null, onChanged: _noop),
      );

      expect(find.text('All'), findsOneWidget);

      for (final category in ToolCategory.values) {
        expect(
          find.text(
            category.label(tester.element(find.byType(ToolCategoryFilter))),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('selects All when selected is null', (tester) async {
      await pumpApp(
        tester,
        ToolCategoryFilter(selected: null, onChanged: _noop),
      );

      final materials = tester.widgetList<Material>(find.byType(Material));

      final theme = Theme.of(tester.element(find.byType(ToolCategoryFilter)));

      expect(
        materials.any(
          (material) => material.color == theme.colorScheme.primary,
        ),
        isTrue,
      );
    });

    testWidgets('calls onChanged with null when All is tapped', (tester) async {
      ToolCategory? selected = ToolCategory.edit;

      await pumpApp(
        tester,
        ToolCategoryFilter(
          selected: selected,
          onChanged: (value) => selected = value,
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('calls onChanged with category when category is tapped', (
      tester,
    ) async {
      ToolCategory? selected;

      await pumpApp(
        tester,
        ToolCategoryFilter(
          selected: null,
          onChanged: (value) => selected = value,
        ),
      );

      final context = tester.element(find.byType(ToolCategoryFilter));

      final category = ToolCategory.values.first;
      final label = category.label(context);

      await tester.tap(find.text(label));
      await tester.pump();

      expect(selected, category);
    });

    testWidgets('selects the supplied category', (tester) async {
      final selectedCategory = ToolCategory.values.first;

      await pumpApp(
        tester,
        ToolCategoryFilter(selected: selectedCategory, onChanged: _noop),
      );

      final context = tester.element(find.byType(ToolCategoryFilter));

      final selectedLabel = selectedCategory.label(context);

      expect(find.text(selectedLabel), findsOneWidget);
    });

    testWidgets('tapping different categories reports each category', (
      tester,
    ) async {
      final selectedCategories = <ToolCategory?>[];

      await pumpApp(
        tester,
        ToolCategoryFilter(selected: null, onChanged: selectedCategories.add),
      );

      final context = tester.element(find.byType(ToolCategoryFilter));

      for (final category in ToolCategory.values) {
        await tester.tap(find.text(category.label(context)));
        await tester.pump();
      }

      expect(selectedCategories, ToolCategory.values);
    });
  });
}

void _noop(ToolCategory? value) {}
