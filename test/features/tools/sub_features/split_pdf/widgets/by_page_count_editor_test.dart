import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ByPageCountEditor', () {
    testWidgets('renders the current page count', (tester) async {
      await pumpApp(
        tester,
        ByPageCountEditor(pageCount: '10', onPageCountChanged: (_) {}),
      );

      expect(
        find.byKey(const ValueKey('split-pages-per-file')),
        findsOneWidget,
      );

      final textField = tester.widget<TextField>(
        find.byKey(const ValueKey('split-pages-per-file')),
      );

      expect(textField.controller?.text, '10');
    });

    testWidgets('uses the expected labels and hint', (tester) async {
      await pumpApp(
        tester,
        ByPageCountEditor(pageCount: '', onPageCountChanged: (_) {}),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitPagesPerFileLabel), findsOneWidget);
      expect(find.text(l10n.toolsSplitPagesPerFileHint), findsOneWidget);
    });

    testWidgets('uses numeric keyboard input', (tester) async {
      await pumpApp(
        tester,
        ByPageCountEditor(pageCount: '', onPageCountChanged: (_) {}),
      );

      final textField = tester.widget<TextField>(
        find.byKey(const ValueKey('split-pages-per-file')),
      );

      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('forwards page count changes', (tester) async {
      String? value;

      await pumpApp(
        tester,
        ByPageCountEditor(
          pageCount: '',
          onPageCountChanged: (pageCount) {
            value = pageCount;
          },
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('split-pages-per-file')),
        '25',
      );

      expect(value, '25');
    });
  });
}
