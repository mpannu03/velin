import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('PageSelectionField', () {
    testWidgets('initializes with supplied value', (tester) async {
      await pumpApp(tester, const PageSelectionField(value: '1-5, last'));
      final field = tester.widget<TextField>(find.byType(TextField));

      expect(field.controller?.text, '1-5, last');
    });

    testWidgets('renders default label and hint', (tester) async {
      await pumpApp(tester, const PageSelectionField(value: ''));

      expect(find.text('Page Selection'), findsOneWidget);
      expect(find.text('e.g. 1-5, 8, last'), findsOneWidget);
    });

    testWidgets('uses custom label and hint', (tester) async {
      await pumpApp(
        tester,
        const PageSelectionField(
          value: '',
          labelText: 'Page range',
          hintText: 'Enter pages',
        ),
      );

      expect(find.text('Page range'), findsOneWidget);
      expect(find.text('Enter pages'), findsOneWidget);
    });

    testWidgets('uses supplied field key', (tester) async {
      const key = ValueKey('page-selection-field');

      await pumpApp(tester, const PageSelectionField(value: '', fieldKey: key));

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('forwards onChanged on every edit', (tester) async {
      final values = <String>[];

      await pumpApp(
        tester,
        PageSelectionField(value: '', onChanged: values.add),
      );

      await tester.enterText(find.byType(TextField), '1-5');

      expect(values, ['1-5']);
    });

    testWidgets('forwards onSubmitted when field is submitted', (tester) async {
      String? submittedValue;

      await pumpApp(
        tester,
        PageSelectionField(
          value: '1-5',
          onSubmitted: (value) => submittedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), '2-6');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, '2-6');
    });

    testWidgets('submits current controller value when tapping outside', (
      tester,
    ) async {
      String? submittedValue;

      await pumpApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              PageSelectionField(
                value: '1-5',
                commitOnTapOutside: true,
                onSubmitted: (value) => submittedValue = value,
              ),
              const Expanded(
                child: SizedBox.expand(key: ValueKey('outside-area')),
              ),
            ],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '2-6, last');
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('outside-area')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(submittedValue, '2-6, last');
    });

    testWidgets('does not submit when tapping outside is disabled', (
      tester,
    ) async {
      String? submittedValue;

      await pumpApp(
        tester,
        PageSelectionField(
          value: '1-5',
          onSubmitted: (value) => submittedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), '2-6');

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(submittedValue, isNull);
    });

    testWidgets('does not submit on tap outside when callback is omitted', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const PageSelectionField(value: '1-5', commitOnTapOutside: true),
      );

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('updates controller when value changes externally', (
      tester,
    ) async {
      await pumpApp(tester, const PageSelectionField(value: '1-5'));

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '1-5',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: PageSelectionField(value: '2-8, last')),
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '2-8, last',
      );
    });

    testWidgets('preserves controller text when parent value is unchanged', (
      tester,
    ) async {
      await pumpApp(tester, const PageSelectionField(value: '1-5'));

      await tester.enterText(find.byType(TextField), '1-5, 8');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: PageSelectionField(value: '1-5, 8')),
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '1-5, 8',
      );
    });

    testWidgets('wraps field with supplied width', (tester) async {
      const width = 320.0;

      await pumpApp(
        tester,
        const PageSelectionField(value: '1-5', width: width),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, width);
    });

    testWidgets('does not add SizedBox when width is omitted', (tester) async {
      await pumpApp(tester, const PageSelectionField(value: '1-5'));

      expect(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(SizedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('forwards keyboard type', (tester) async {
      await pumpApp(
        tester,
        const PageSelectionField(value: '', keyboardType: TextInputType.number),
      );

      final field = tester.widget<TextField>(find.byType(TextField));

      expect(field.keyboardType, TextInputType.number);
    });

    testWidgets('forwards autofocus', (tester) async {
      await pumpApp(
        tester,
        const PageSelectionField(value: '', autofocus: true),
      );

      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    });
  });
}
