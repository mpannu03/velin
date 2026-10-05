import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

enum _TestPageScope {
all,
selected,
}

void main() {
  group('PageScopeEditor', () {
    testWidgets('renders both page scope options', (tester) async {
    await pumpApp(
      tester,
      const PageScopeEditor<_TestPageScope>(
        allPagesScope: _TestPageScope.all,
        selectedPagesScope: _TestPageScope.selected,
        scope: _TestPageScope.all,
        requiresSelection: false,
        allPagesLabel: 'All pages',
        selectedPagesLabel: 'Selected pages',
        selection: '',
        onScopeChanged: _noopScopeChanged,
        onSelectionChanged: _noopSelectionChanged,
      ),
    );

    expect(find.text('All pages'), findsOneWidget);
    expect(find.text('Selected pages'), findsOneWidget);
    expect(find.byType(SegmentedButton<_TestPageScope>), findsOneWidget);
  });

    testWidgets(
      'does not show page selection when selection is not required',
      (tester) async {
        await pumpApp(
          tester,
          const PageScopeEditor<_TestPageScope>(
            allPagesScope: _TestPageScope.all,
            selectedPagesScope: _TestPageScope.selected,
            scope: _TestPageScope.all,
            requiresSelection: false,
            allPagesLabel: 'All pages',
            selectedPagesLabel: 'Selected pages',
            selection: '1-5',
            onScopeChanged: _noopScopeChanged,
            onSelectionChanged: _noopSelectionChanged,
          ),
        );

        expect(find.byType(PageSelectionField), findsNothing);
        expect(find.byType(HelperText), findsNothing);
      },
    );

    testWidgets(
      'shows page selection when selection is required',
      (tester) async {
        await pumpApp(
          tester,
          const PageScopeEditor<_TestPageScope>(
            allPagesScope: _TestPageScope.all,
            selectedPagesScope: _TestPageScope.selected,
            scope: _TestPageScope.selected,
            requiresSelection: true,
            allPagesLabel: 'All pages',
            selectedPagesLabel: 'Selected pages',
            selection: '1-5, last',
            onScopeChanged: _noopScopeChanged,
            onSelectionChanged: _noopSelectionChanged,
          ),
        );

        expect(find.byType(PageSelectionField), findsOneWidget);
      },
    );

    testWidgets('shows supplied selection value', (tester) async {
      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5, last',
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      expect(find.text('1-5, last'), findsOneWidget);
    });

    testWidgets('selection helper text is optional', (tester) async {
      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5',
          selectionHelperText: 'Use commas, ranges, odd, even, or last.',
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      expect(
        find.text('Use commas, ranges, odd, even, or last.'),
        findsOneWidget,
      );
      expect(find.byType(HelperText), findsOneWidget);
    });

    testWidgets('does not show helper text when omitted', (tester) async {
      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5',
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      expect(find.byType(HelperText), findsNothing);
    });

    testWidgets('scope change is forwarded', (tester) async {
      _TestPageScope? selectedScope;

      await pumpApp(
        tester,
        PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.all,
          requiresSelection: false,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '',
          onScopeChanged: (scope) => selectedScope = scope,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      final segmentedButton = tester.widget<
          SegmentedButton<_TestPageScope>>(
        find.byType(SegmentedButton<_TestPageScope>),
      );

      segmentedButton.onSelectionChanged?.call({
        _TestPageScope.selected,
      });

      expect(selectedScope, _TestPageScope.selected);
    });

    testWidgets('selection change is forwarded', (tester) async {
      String? selectedPages;

      await pumpApp(
        tester,
        PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5',
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: (value) => selectedPages = value,
        ),
      );

      final field = tester.widget<PageSelectionField>(
        find.byType(PageSelectionField),
      );

      field.onChanged?.call('2-6, last');

      expect(selectedPages, '2-6, last');
    });

    testWidgets('uses supplied scope key', (tester) async {
      const key = ValueKey('page-scope');

      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.all,
          requiresSelection: false,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '',
          scopeKey: key,
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('uses supplied selection field key', (tester) async {
      const key = ValueKey('page-selection');

      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.selected,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5',
          selectionFieldKey: key,
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('passes custom selection field width', (tester) async {
      const width = 320.0;

      await pumpApp(
        tester,
        const PageScopeEditor<_TestPageScope>(
          allPagesScope: _TestPageScope.all,
          selectedPagesScope: _TestPageScope.selected,
          scope: _TestPageScope.selected,
          requiresSelection: true,
          allPagesLabel: 'All pages',
          selectedPagesLabel: 'Selected pages',
          selection: '1-5',
          selectionFieldWidth: width,
          onScopeChanged: _noopScopeChanged,
          onSelectionChanged: _noopSelectionChanged,
        ),
      );

      final field = tester.widget<PageSelectionField>(
        find.byType(PageSelectionField),
      );

      expect(field.width, width);
    });
  });
}

void _noopScopeChanged(_TestPageScope scope) {}

void _noopSelectionChanged(String value) {}
