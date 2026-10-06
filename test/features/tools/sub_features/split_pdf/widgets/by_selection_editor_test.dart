import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('BySelectionEditor', () {
    testWidgets('shows hint when there are no selections', (tester) async {
      await pumpApp(
        tester,
        BySelectionEditor(
          selections: const [],
          onSelectionChanged: (_, _) {},
          onAddSelection: () {},
          onRemoveSelection: (_) {},
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitSelectionHint), findsOneWidget);
      expect(find.text(l10n.toolsSplitSelectionAdd), findsOneWidget);
    });

    testWidgets('renders all selections with their indexes', (tester) async {
      await pumpApp(
        tester,
        BySelectionEditor(
          selections: const ['1-5', '10', 'odd'],
          onSelectionChanged: (_, _) {},
          onAddSelection: () {},
          onRemoveSelection: (_) {},
        ),
      );

      expect(find.byKey(const ValueKey('selection-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-2')), findsOneWidget);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      expect(find.byKey(const ValueKey('selection-field-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-field-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection-field-2')), findsOneWidget);
    });

    testWidgets('forwards selection changes', (tester) async {
      int? changedIndex;
      String? changedValue;

      await pumpApp(
        tester,
        BySelectionEditor(
          selections: const ['1-5'],
          onSelectionChanged: (index, value) {
            changedIndex = index;
            changedValue = value;
          },
          onAddSelection: () {},
          onRemoveSelection: (_) {},
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('selection-field-0')),
        '2-8',
      );

      expect(changedIndex, 0);
      expect(changedValue, '2-8');
    });

    testWidgets('forwards add selection action', (tester) async {
      var added = false;

      await pumpApp(
        tester,
        BySelectionEditor(
          selections: const [],
          onSelectionChanged: (_, _) {},
          onAddSelection: () {
            added = true;
          },
          onRemoveSelection: (_) {},
        ),
      );

      await tester.tap(
        find.text(
          lookupAppLocalizations(const Locale('en')).toolsSplitSelectionAdd,
        ),
      );

      expect(added, isTrue);
    });

    testWidgets('forwards remove selection action with index', (tester) async {
      int? removedIndex;

      await pumpApp(
        tester,
        BySelectionEditor(
          selections: const ['1-5', '10'],
          onSelectionChanged: (_, _) {},
          onAddSelection: () {},
          onRemoveSelection: (index) {
            removedIndex = index;
          },
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      final removeButtons = find.byTooltip(l10n.toolsSplitSelectionRemove);

      expect(removeButtons, findsNWidgets(2));

      await tester.tap(removeButtons.at(1));

      expect(removedIndex, 1);
    });
  });
}
