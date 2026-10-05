import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('MultiFilePicker', () {
    MultiFilePicker buildPicker({
      List<String> filePaths = const [],
      VoidCallback? onAddFiles,
      ValueChanged<int>? onRemoveFile,
      void Function(int oldIndex, int newIndex)? onReorderItem,
      String emptyStateDescription = 'Add PDF files to begin.',
      List<String?>? pageSelections,
      bool showPageSelection = false,
      void Function(int index, String value)? onPageSelectionChanged,
    }) {
      return MultiFilePicker(
        filePaths: filePaths,
        onAddFiles: onAddFiles ?? () {},
        onRemoveFile: onRemoveFile ?? (_) {},
        onReorderItem: onReorderItem ?? (_, _) {},
        emptyStateDescription: emptyStateDescription,
        pageSelections: pageSelections,
        showPageSelection: showPageSelection,
        onPageSelectionChanged: onPageSelectionChanged,
      );
    }

    group('empty state', () {
      testWidgets('shows empty state when there are no files', (
        tester,
      ) async {
        await pumpApp(
          tester,
          buildPicker(
            emptyStateDescription: 'Add PDF files to begin.',
          ),
        );

        expect(find.text('Add files'), findsNWidgets(2));
        expect(find.text('No files added'), findsOneWidget);
        expect(
          find.text('Add PDF files to begin.'),
          findsOneWidget,
        );
      });

      testWidgets('shows add files button in the header', (tester) async {
        var callCount = 0;

        await pumpApp(
          tester,
          buildPicker(
            onAddFiles: () => callCount++,
          ),
        );

        final button = find.widgetWithText(
          OutlinedButton,
          'Add files',
        );

        expect(button, findsOneWidget);

        await tester.tap(button);
        await tester.pump();

        expect(callCount, 1);
      });

      testWidgets('shows add files button in the empty state', (
        tester,
      ) async {
        var callCount = 0;

        await pumpApp(
          tester,
          buildPicker(
            onAddFiles: () => callCount++,
          ),
        );

        final buttons = find.text('Add files');

        expect(buttons, findsNWidgets(2));

        await tester.tap(buttons.last);
        await tester.pump();

        expect(callCount, 1);
      });

      testWidgets('uses the supplied empty state description', (
        tester,
      ) async {
        await pumpApp(
          tester,
          buildPicker(
            emptyStateDescription: 'Select PDFs that should be merged.',
          ),
        );

        expect(
          find.text('Select PDFs that should be merged.'),
          findsOneWidget,
        );
      });
    });

    group('files', () {
      testWidgets('shows file count', (tester) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
              '/documents/third.pdf',
            ],
          ),
        );

        expect(find.text('3 files'), findsOneWidget);
      });

      testWidgets('shows selected files', (tester) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
          ),
        );

        expect(find.byType(SelectedFileItem), findsNWidgets(2));
        expect(find.text('first.pdf'), findsOneWidget);
        expect(find.text('second.pdf'), findsOneWidget);
      });

      testWidgets('shows one-based file indexes', (tester) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
          ),
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('does not show empty state when files exist', (
        tester,
      ) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const ['/documents/first.pdf'],
          ),
        );

        expect(find.text('No files added'), findsNothing);
        expect(find.byType(SelectedFileItem), findsOneWidget);
      });
    });

    group('remove', () {
      testWidgets('forwards the correct file index', (tester) async {
        int? removedIndex;

        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
              '/documents/third.pdf',
            ],
            onRemoveFile: (index) {
              removedIndex = index;
            },
          ),
        );

        final secondItem = find.ancestor(
          of: find.text('second.pdf'),
          matching: find.byType(SelectedFileItem),
        );

        expect(secondItem, findsOneWidget);

        await tester.tap(
          find.descendant(
            of: secondItem,
            matching: find.byTooltip('Remove file'),
          ),
        );
        await tester.pump();

        expect(removedIndex, 1);
      });
    });

    group('reorder', () {
      testWidgets('forwards reorder indexes', (tester) async {
        int? oldIndex;
        int? newIndex;

        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
              '/documents/third.pdf',
            ],
            onReorderItem: (from, to) {
              oldIndex = from;
              newIndex = to;
            },
          ),
        );

        final list = find.byType(ReorderableListView);

        expect(list, findsOneWidget);

        // Drag by slightly more than one row (58px) so the item lands on the
        // next slot instead of skipping over it.
        await tester.drag(
          find.byIcon(Icons.drag_indicator).first,
          const Offset(0, 100),
        );
        await tester.pumpAndSettle();

        expect(oldIndex, 0);
        expect(newIndex, 2);
      });

      testWidgets('does not reorder when the drag stays within the item', (
        tester,
      ) async {
        var callCount = 0;

        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
            onReorderItem: (_, _) => callCount++,
          ),
        );

        await tester.drag(
          find.byIcon(Icons.drag_indicator).first,
          const Offset(0, 5),
        );
        await tester.pumpAndSettle();

        expect(callCount, 0);
      });
    });

    group('page selection', () {
      testWidgets('hides page selection by default', (tester) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const ['/documents/first.pdf'],
          ),
        );

        expect(find.byType(TextFormField), findsNothing);
      });

      testWidgets('shows page selection for every file when enabled', (
        tester,
      ) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
            pageSelections: const ['1-5', '2,4'],
            showPageSelection: true,
          ),
        );

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('1-5'), findsOneWidget);
        expect(find.text('2,4'), findsOneWidget);
      });

      testWidgets('forwards page selection changes with the file index', (
        tester,
      ) async {
        int? changedIndex;
        String? changedValue;

        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
            pageSelections: const ['', '1-5'],
            showPageSelection: true,
            onPageSelectionChanged: (index, value) {
              changedIndex = index;
              changedValue = value;
            },
          ),
        );

        final fields = find.byType(TextFormField);

        await tester.enterText(fields.at(1), '2-6');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        expect(changedIndex, 1);
        expect(changedValue, '2-6');
      });

      testWidgets(
        'handles missing page selections for some files',
        (tester) async {
          await pumpApp(
            tester,
            buildPicker(
              filePaths: const [
                '/documents/first.pdf',
                '/documents/second.pdf',
              ],
              pageSelections: const ['1-5'],
              showPageSelection: true,
            ),
          );

          final fields = find.byType(TextFormField);

          expect(fields, findsNWidgets(2));

          expect(
            tester.widget<TextFormField>(fields.at(0)).initialValue,
            '1-5',
          );
          expect(
            tester.widget<TextFormField>(fields.at(1)).initialValue,
            '',
          );
        },
      );
    });

    group('drag handles', () {
      testWidgets('shows a drag handle for each file', (tester) async {
        await pumpApp(
          tester,
          buildPicker(
            filePaths: const [
              '/documents/first.pdf',
              '/documents/second.pdf',
            ],
          ),
        );

        expect(
          find.byIcon(Icons.drag_indicator),
          findsNWidgets(2),
        );
      });
    });
  });
}