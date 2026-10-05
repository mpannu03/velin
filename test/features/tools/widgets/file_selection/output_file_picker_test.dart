import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('OutputFilePicker', () {
    testWidgets('shows output section', (tester) async {
      await pumpApp(
        tester,
        OutputFilePicker(directoryPath: null, onChooseFolder: () {}),
      );

      expect(find.text('Output'), findsOneWidget);
    });

    testWidgets('shows empty filename when fileName is null', (tester) async {
      await pumpApp(
        tester,
        OutputFilePicker(directoryPath: null, onChooseFolder: () {}),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('output-file-name')),
      );

      expect(field.controller!.text, '');
    });

    testWidgets('shows supplied filename', (tester) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: 'merged.pdf',
          onChooseFolder: () {},
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('output-file-name')),
      );

      expect(field.controller!.text, 'merged.pdf');
      expect(find.text('merged.pdf'), findsOneWidget);
    });

    testWidgets('calls onFileNameChanged when filename is submitted', (
      tester,
    ) async {
      String? changedValue;

      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: 'merged.pdf',
          onFileNameChanged: (value) {
            changedValue = value;
          },
          onChooseFolder: () {},
        ),
      );

      final field = find.byKey(const ValueKey('output-file-name'));

      await tester.enterText(field, 'final.pdf');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changedValue, 'final.pdf');
    });

    testWidgets(
      'calls onFileNameChanged with current value when tapping outside',
      (tester) async {
        String? changedValue;

        await pumpApp(
          tester,
          OutputFilePicker(
            directoryPath: '/documents/output',
            fileName: 'merged.pdf',
            onFileNameChanged: (value) {
              changedValue = value;
            },
            onChooseFolder: () {},
          ),
        );

        final field = find.byKey(const ValueKey('output-file-name'));

        await tester.tap(field);
        await tester.enterText(field, 'final.pdf');

        // Tap outside the text field.
        await tester.tapAt(const Offset(10, 10));
        await tester.pump();

        expect(changedValue, 'final.pdf');
      },
    );

    testWidgets('shows choose output folder when directory is missing', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(directoryPath: null, onChooseFolder: () {}),
      );

      expect(find.text('Choose an output folder'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_outlined), findsNWidgets(2));
    });

    testWidgets('shows directory when selected', (tester) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          onChooseFolder: () {},
        ),
      );

      expect(
        find.byKey(const ValueKey('output-directory-row')),
        findsOneWidget,
      );
    });

    testWidgets('calls onChooseFolder from choose folder button', (
      tester,
    ) async {
      var callCount = 0;

      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: null,
          onChooseFolder: () => callCount++,
        ),
      );

      await tester.tap(find.text('Choose folder'));
      await tester.pump();

      expect(callCount, 1);
    });

    testWidgets('calls onChooseFolder when directory row is tapped', (
      tester,
    ) async {
      var callCount = 0;

      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          onChooseFolder: () => callCount++,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('output-directory-row')));
      await tester.pump();

      expect(callCount, 1);
    });

    testWidgets('shows save-as preview when directory and filename exist', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: 'merged.pdf',
          onChooseFolder: () {},
        ),
      );

      expect(
        find.text('Will save as: /documents/output/merged.pdf'),
        findsOneWidget,
      );
    });

    testWidgets('normalizes directory separators in save-as preview', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: r'C:\Documents\Output',
          fileName: 'merged.pdf',
          onChooseFolder: () {},
        ),
      );

      expect(
        find.text('Will save as: C:/Documents/Output/merged.pdf'),
        findsOneWidget,
      );
    });

    testWidgets('shows directory instead of save-as preview without filename', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          onChooseFolder: () {},
        ),
      );

      expect(find.text('/documents/output'), findsNWidgets(2));
    });

    testWidgets('hides filename controls when showFileName is false', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: 'merged.pdf',
          showFileName: false,
          onChooseFolder: () {},
        ),
      );

      expect(find.byKey(const ValueKey('output-file-name')), findsNothing);
      expect(
        find.text('Will save as: /documents/output/merged.pdf'),
        findsNothing,
      );
      expect(find.text('/documents/output'), findsOneWidget);
    });

    testWidgets('shows directory when showFileName is false', (tester) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: 'merged.pdf',
          showFileName: false,
          onChooseFolder: () {},
        ),
      );

      expect(find.text('/documents/output'), findsOneWidget);
    });

    testWidgets('uses output path hint when directory is missing', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OutputFilePicker(
          directoryPath: null,
          fileName: 'merged.pdf',
          onChooseFolder: () {},
        ),
      );

      expect(find.text('Choose an output folder'), findsOneWidget);
    });

    testWidgets('updates filename field when parent changes fileName', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: _OutputFilePickerHost()),
        ),
      );

      expect(find.byKey(const ValueKey('output-file-name')), findsOneWidget);

      final initialField = tester.widget<TextField>(
        find.byKey(const ValueKey('output-file-name')),
      );

      expect(initialField.controller!.text, 'first.pdf');

      await tester.tap(find.text('Change filename'));
      await tester.pump();

      final updatedField = tester.widget<TextField>(
        find.byKey(const ValueKey('output-file-name')),
      );

      expect(updatedField.controller!.text, 'second.pdf');
    });
  });
}

class _OutputFilePickerHost extends StatefulWidget {
  const _OutputFilePickerHost();

  @override
  State<_OutputFilePickerHost> createState() => _OutputFilePickerHostState();
}

class _OutputFilePickerHostState extends State<_OutputFilePickerHost> {
  var _fileName = 'first.pdf';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutputFilePicker(
          directoryPath: '/documents/output',
          fileName: _fileName,
          onChooseFolder: () {},
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _fileName = 'second.pdf';
            });
          },
          child: const Text('Change filename'),
        ),
      ],
    );
  }
}
