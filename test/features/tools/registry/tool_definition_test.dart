import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolDefinition', () {
    test('stores supplied values', () {
      const tool = ToolDefinition(
        id: ToolId.mergePdf,
        category: ToolCategory.edit,
        icon: Icons.merge_type,
        route: '/tools/merge-pdf',
      );

      expect(tool.id, ToolId.mergePdf);
      expect(tool.category, ToolCategory.edit);
      expect(tool.icon, Icons.merge_type);
      expect(tool.route, '/tools/merge-pdf');
    });
  });

  group('ToolDefinitionX', () {
    testWidgets('every tool has a title', (tester) async {
      await pumpApp(tester, const SizedBox());

      final context = tester.element(find.byType(SizedBox));

      for (final id in ToolId.values) {
        final tool = ToolDefinition(
          id: id,
          category: ToolCategory.edit,
          icon: Icons.build,
          route: '/tools/test',
        );

        expect(tool.title(context), isNotEmpty);
      }
    });

    testWidgets('every tool has a description', (tester) async {
      await pumpApp(tester, const SizedBox());

      final context = tester.element(find.byType(SizedBox));

      for (final id in ToolId.values) {
        final tool = ToolDefinition(
          id: id,
          category: ToolCategory.edit,
          icon: Icons.build,
          route: '/tools/test',
        );

        expect(tool.description(context), isNotEmpty);
      }
    });
  });

  group('ToolCategoryX', () {
    testWidgets('every category has a label', (tester) async {
      await pumpApp(tester, const SizedBox());

      final context = tester.element(find.byType(SizedBox));

      for (final category in ToolCategory.values) {
        expect(category.label(context), isNotEmpty);
      }
    });
  });
}
