import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('SplitModeEditor', () {
    SplitModeEditor buildEditor({
      SplitPdfMode mode = SplitPdfMode.byPageCount,
      ValueChanged<SplitPdfMode>? onModeChanged,
      String pageCount = '10',
      ValueChanged<String>? onPageCountChanged,
      List<String> selections = const [],
      void Function(int index, String value)? onSelectionChanged,
      VoidCallback? onAddSelection,
      ValueChanged<int>? onRemoveSelection,
    }) {
      return SplitModeEditor(
        mode: mode,
        onModeChanged: onModeChanged ?? (_) {},
        pageCount: pageCount,
        onPageCountChanged: onPageCountChanged ?? (_) {},
        selections: selections,
        onSelectionChanged: onSelectionChanged ?? (_, _) {},
        onAddSelection: onAddSelection ?? () {},
        onRemoveSelection: onRemoveSelection ?? (_) {},
      );
    }

    testWidgets('renders all supported modes', (tester) async {
      await pumpApp(tester, buildEditor());

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitModeByPageCount), findsOneWidget);
      expect(find.text(l10n.toolsSplitModeBySelection), findsOneWidget);
      expect(find.text(l10n.toolsSplitModeExtractAll), findsOneWidget);
    });

    testWidgets('shows page count editor for page count mode', (tester) async {
      await pumpApp(
        tester,
        buildEditor(mode: SplitPdfMode.byPageCount, pageCount: '15'),
      );

      expect(find.byType(ByPageCountEditor), findsOneWidget);
      expect(
        find.byKey(const ValueKey('split-pages-per-file')),
        findsOneWidget,
      );

      final textField = tester.widget<TextField>(
        find.byKey(const ValueKey('split-pages-per-file')),
      );

      expect(textField.controller?.text, '15');
    });

    testWidgets('shows selection editor for selection mode', (tester) async {
      await pumpApp(
        tester,
        buildEditor(
          mode: SplitPdfMode.bySelection,
          selections: const ['1-5', '10'],
        ),
      );

      expect(find.byType(BySelectionEditor), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-field-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-field-1')), findsOneWidget);
    });

    testWidgets('shows extract all information for extract mode', (
      tester,
    ) async {
      await pumpApp(tester, buildEditor(mode: SplitPdfMode.extractAllPages));

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitExtractAllInfo), findsOneWidget);
      expect(find.byType(ByPageCountEditor), findsNothing);
      expect(find.byType(BySelectionEditor), findsNothing);
    });

    testWidgets('forwards mode changes', (tester) async {
      SplitPdfMode? selectedMode;

      await pumpApp(
        tester,
        buildEditor(
          onModeChanged: (mode) {
            selectedMode = mode;
          },
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<SplitPdfMode>>(
        find.byType(SegmentedButton<SplitPdfMode>),
      );

      segmentedButton.onSelectionChanged?.call({SplitPdfMode.bySelection});

      expect(selectedMode, SplitPdfMode.bySelection);
    });

    testWidgets('forwards page count changes', (tester) async {
      String? changedPageCount;

      await pumpApp(
        tester,
        buildEditor(
          pageCount: '',
          onPageCountChanged: (value) {
            changedPageCount = value;
          },
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('split-pages-per-file')),
        '25',
      );

      expect(changedPageCount, '25');
    });

    testWidgets('passes selection callbacks to selection editor', (
      tester,
    ) async {
      int? changedIndex;
      String? changedValue;
      var added = false;
      int? removedIndex;

      await pumpApp(
        tester,
        buildEditor(
          mode: SplitPdfMode.bySelection,
          selections: const ['1-5'],
          onSelectionChanged: (index, value) {
            changedIndex = index;
            changedValue = value;
          },
          onAddSelection: () {
            added = true;
          },
          onRemoveSelection: (index) {
            removedIndex = index;
          },
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('selection-field-0')),
        '2-8',
      );

      expect(changedIndex, 0);
      expect(changedValue, '2-8');

      final l10n = lookupAppLocalizations(const Locale('en'));

      await tester.tap(find.text(l10n.toolsSplitSelectionAdd));

      expect(added, isTrue);

      await tester.tap(find.byTooltip(l10n.toolsSplitSelectionRemove));

      expect(removedIndex, 0);
    });
  });
}
