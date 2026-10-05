import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SingleFilePicker', () {
    group('empty state', () {
      testWidgets('shows empty state when filePath is null', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            onPickFile: () {},
          ),
        );

        expect(find.text('No file selected'), findsOneWidget);
        expect(find.text('Choose file'), findsOneWidget);
        expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
      });

      testWidgets('shows empty state when filePath is empty', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: '',
            onPickFile: () {},
          ),
        );

        expect(find.text('No file selected'), findsOneWidget);
        expect(find.text('Choose file'), findsOneWidget);
      });

      testWidgets('shows default description when none is supplied', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            onPickFile: () {},
          ),
        );

        expect(
          find.text('Choose a file to get started'),
          findsOneWidget,
        );
      });

      testWidgets('shows the supplied empty state description', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            onPickFile: () {},
            emptyStateDescription: 'Select a PDF to extract pages.',
          ),
        );

        expect(
          find.text('Select a PDF to extract pages.'),
          findsOneWidget,
        );
      });

      testWidgets('calls onPickFile when choose file is tapped', (
        tester,
      ) async {
        var callCount = 0;

        await pumpApp(
          tester,
          SingleFilePicker(
            onPickFile: () => callCount++,
          ),
        );

        await tester.tap(find.text('Choose file'));
        await tester.pump();

        expect(callCount, 1);
      });
    });

    group('selected file', () {
      testWidgets('shows the selected file name and directory', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: '/documents/pdfs/report.pdf',
            onPickFile: () {},
          ),
        );

        expect(find.text('report.pdf'), findsOneWidget);
        expect(find.text('/documents/pdfs'), findsOneWidget);
        expect(find.text('No file selected'), findsNothing);
      });

      testWidgets('supports Windows paths', (tester) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: r'C:\Documents\PDFs\report.pdf',
            onPickFile: () {},
          ),
        );

        expect(find.text('report.pdf'), findsOneWidget);
        expect(find.text(r'C:\Documents\PDFs'), findsOneWidget);
      });

      testWidgets('shows empty directory for a filename without a path', (
        tester,
      ) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: 'report.pdf',
            onPickFile: () {},
          ),
        );

        expect(find.text('report.pdf'), findsOneWidget);
        expect(find.text(''), findsOneWidget);
      });

      testWidgets('shows replace file button', (tester) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: '/documents/report.pdf',
            onPickFile: () {},
          ),
        );

        expect(find.text('Replace file'), findsOneWidget);
        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      });

      testWidgets('calls onPickFile when replace file is tapped', (
        tester,
      ) async {
        var callCount = 0;

        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: '/documents/report.pdf',
            onPickFile: () => callCount++,
          ),
        );

        await tester.tap(find.text('Replace file'));
        await tester.pump();

        expect(callCount, 1);
      });

      testWidgets('does not show empty state controls', (tester) async {
        await pumpApp(
          tester,
          SingleFilePicker(
            filePath: '/documents/report.pdf',
            onPickFile: () {},
          ),
        );

        expect(find.text('No file selected'), findsNothing);
        expect(find.text('Choose file'), findsNothing);
      });
    });
  });
}