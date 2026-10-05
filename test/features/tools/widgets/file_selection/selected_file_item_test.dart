import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SelectedFileItem', () {
    testWidgets('shows the file name and directory', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/pdfs/report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('/documents/pdfs'), findsOneWidget);
    });

    testWidgets('shows only file name when path has no directory', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: 'report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.textContaining('/'), findsNothing);
    });

    testWidgets('supports Windows paths', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: r'C:\Documents\PDFs\report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text(r'C:\Documents\PDFs'), findsOneWidget);
    });

    testWidgets('shows index when provided', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          index: 3,
          onRemove: () {},
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('does not show index when not provided', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('shows drag handle when provided', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
          dragHandle: const Icon(Icons.drag_indicator),
        ),
      );

      expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
    });

    testWidgets('does not show drag handle when not provided', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.byIcon(Icons.drag_indicator), findsNothing);
    });

    testWidgets('hides page selection by default', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
        ),
      );

      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Pages'), findsNothing);
    });

    testWidgets('shows page selection when enabled', (tester) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
          showPageSelection: true,
          pageSelection: '1-5',
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('1-5'), findsOneWidget);
      expect(find.text('Page Selection'), findsOneWidget);
    });

    testWidgets('uses empty value when page selection is null', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
          showPageSelection: true,
        ),
      );

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );

      expect(field.initialValue, '');
    });

    testWidgets('initializes page selection with provided value', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
          showPageSelection: true,
          pageSelection: '1,3,5',
        ),
      );

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );

      expect(field.initialValue, '1,3,5');
    });

    testWidgets('calls onPageSelectionChanged when submitted', (
      tester,
    ) async {
      String? submittedValue;

      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () {},
          showPageSelection: true,
          pageSelection: '1-5',
          onPageSelectionChanged: (value) {
            submittedValue = value;
          },
        ),
      );

      final field = find.byType(TextFormField);

      await tester.enterText(field, '2-6');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, '2-6');
    });

    testWidgets('calls onRemove when remove button is tapped', (
      tester,
    ) async {
      var removed = false;

      await pumpApp(
        tester,
        SelectedFileItem(
          filePath: '/documents/report.pdf',
          onRemove: () => removed = true,
        ),
      );

      final removeButton = find.byTooltip('Remove file');

      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pump();

      expect(removed, isTrue);
    });
  });
}
