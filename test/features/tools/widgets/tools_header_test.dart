import 'package:flutter_test/flutter_test.dart';

import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('Header', () {
    testWidgets('renders tools title and introduction', (tester) async {
      await pumpApp(tester, Header(filter: null, onFilterChanged: _noop));

      expect(
        find.text(tester.element(find.byType(Header)).l10n.navigationTools),
        findsOneWidget,
      );
      expect(
        find.text(tester.element(find.byType(Header)).l10n.toolsIntro),
        findsOneWidget,
      );
    });

    testWidgets('renders category filter', (tester) async {
      await pumpApp(tester, Header(filter: null, onFilterChanged: _noop));

      expect(find.byType(ToolCategoryFilter), findsOneWidget);
    });

    testWidgets('passes selected filter to category filter', (tester) async {
      final selectedCategory = ToolCategory.values.first;

      await pumpApp(
        tester,
        Header(filter: selectedCategory, onFilterChanged: _noop),
      );

      final filter = tester.widget<ToolCategoryFilter>(
        find.byType(ToolCategoryFilter),
      );

      expect(filter.selected, selectedCategory);
    });

    testWidgets('forwards filter changes', (tester) async {
      ToolCategory? changedValue;

      await pumpApp(
        tester,
        Header(filter: null, onFilterChanged: (value) => changedValue = value),
      );

      final filter = tester.widget<ToolCategoryFilter>(
        find.byType(ToolCategoryFilter),
      );

      filter.onChanged(ToolCategory.values.first);

      expect(changedValue, ToolCategory.values.first);
    });
  });
}

void _noop(ToolCategory? value) {}
