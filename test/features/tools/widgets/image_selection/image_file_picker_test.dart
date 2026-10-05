import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ImageFilePicker', () {
    testWidgets('renders empty state when there are no files', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePicker(
          filePaths: [],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images to create a PDF.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      expect(find.text('Add images to create a PDF.'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byType(ImageFilePickerGrid), findsNothing);
      expect(find.byType(ImageFilePickerItem), findsNothing);
    });

    testWidgets('renders list view when list mode is selected', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePicker(
          filePaths: ['images/one.png', 'images/two.png'],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      expect(find.byType(ImageFilePickerItem), findsNWidgets(2));
      expect(find.byType(ImageFilePickerGrid), findsNothing);
      expect(find.text('one.png'), findsOneWidget);
      expect(find.text('two.png'), findsOneWidget);
    });

    testWidgets('renders grid view when grid mode is selected', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePicker(
          filePaths: ['images/one.png', 'images/two.png'],
          viewMode: ImagePickerViewMode.grid,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      expect(find.byType(ImageFilePickerGrid), findsOneWidget);
      expect(find.byType(ImageFilePickerItem), findsNothing);
    });

    testWidgets('add files button invokes callback', (tester) async {
      var addFilesCalled = 0;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const ['images/one.png'],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images.',
          onAddFiles: () => addFilesCalled++,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      final addButton = find.widgetWithText(OutlinedButton, 'Add files');

      expect(addButton, findsOneWidget);

      await tester.tap(addButton);

      expect(addFilesCalled, 1);
    });

    testWidgets('empty state add button invokes callback', (tester) async {
      var addFilesCalled = 0;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const [],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images.',
          onAddFiles: () => addFilesCalled++,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      final addButtons = find.widgetWithText(FilledButton, 'Add files');

      expect(addButtons, findsOneWidget);

      await tester.tap(addButtons);

      expect(addFilesCalled, 1);
    });

    testWidgets('view mode toggle reports list selection', (tester) async {
      ImagePickerViewMode? selectedMode;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const ['images/one.png'],
          viewMode: ImagePickerViewMode.grid,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: (mode) => selectedMode = mode,
        ),
      );

      final toggle = find.byKey(const ValueKey('image-file-picker-view-mode'));

      expect(toggle, findsOneWidget);

      final segmentedButton = tester
          .widget<SegmentedButton<ImagePickerViewMode>>(toggle);

      segmentedButton.onSelectionChanged?.call({ImagePickerViewMode.list});

      expect(selectedMode, ImagePickerViewMode.list);
    });

    testWidgets('view mode toggle reports grid selection', (tester) async {
      ImagePickerViewMode? selectedMode;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const ['images/one.png'],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: (mode) => selectedMode = mode,
        ),
      );

      final toggle = find.byKey(const ValueKey('image-file-picker-view-mode'));

      final segmentedButton = tester
          .widget<SegmentedButton<ImagePickerViewMode>>(toggle);

      segmentedButton.onSelectionChanged?.call({ImagePickerViewMode.grid});

      expect(selectedMode, ImagePickerViewMode.grid);
    });

    testWidgets('remove callback is delegated in list mode', (tester) async {
      int? removedIndex;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const ['images/one.png', 'images/two.png'],
          viewMode: ImagePickerViewMode.list,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: (index) => removedIndex = index,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      final removeButtons = find.byTooltip('Remove file');

      expect(removeButtons, findsNWidgets(2));

      await tester.tap(removeButtons.at(1));

      expect(removedIndex, 1);
    });

    testWidgets('remove callback is delegated in grid mode', (tester) async {
      int? removedIndex;

      await pumpApp(
        tester,
        ImageFilePicker(
          filePaths: const ['images/one.png', 'images/two.png'],
          viewMode: ImagePickerViewMode.grid,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: (index) => removedIndex = index,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      final removeButtons = find.byTooltip('Remove file');

      expect(removeButtons, findsNWidgets(2));

      await tester.tap(removeButtons.at(1));

      expect(removedIndex, 1);
    });

    testWidgets('uses supplied empty state description', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePicker(
          filePaths: [],
          viewMode: ImagePickerViewMode.grid,
          emptyStateDescription: 'Choose photos for your document.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      expect(find.text('Choose photos for your document.'), findsOneWidget);
    });

    testWidgets('view mode toggle is present even when empty', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePicker(
          filePaths: [],
          viewMode: ImagePickerViewMode.grid,
          emptyStateDescription: 'Add images.',
          onAddFiles: _noop,
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
          onViewModeChanged: _noopViewMode,
        ),
      );

      expect(
        find.byKey(const ValueKey('image-file-picker-view-mode')),
        findsOneWidget,
      );
    });
  });
}

void _noop() {}

void _noopRemove(int index) {}

void _noopReorder(int oldIndex, int newIndex) {}

void _noopViewMode(ImagePickerViewMode mode) {}
