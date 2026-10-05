import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ImageFilePickerGrid', () {
    testWidgets('renders nothing when file list is empty', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: [],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      expect(find.byType(ImageFilePickerGrid), findsOneWidget);
      expect(find.byType(ImageOrderBadge), findsNothing);
    });

    testWidgets('renders one tile for each file', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: ['images/one.png', 'images/two.png', 'images/three.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      expect(find.byType(ImageFilePickerGrid), findsOneWidget);
      expect(find.byType(ImageFileThumbnail), findsNWidgets(3));
      expect(find.text('one.png'), findsOneWidget);
      expect(find.text('two.png'), findsOneWidget);
      expect(find.text('three.png'), findsOneWidget);
    });

    testWidgets('shows one-based order badge for each tile', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: ['images/one.png', 'images/two.png', 'images/three.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('remove button invokes callback with correct index', (
      tester,
    ) async {
      int? removedIndex;

      await pumpApp(
        tester,
        ImageFilePickerGrid(
          filePaths: const ['images/one.png', 'images/two.png'],
          onRemoveFile: (index) => removedIndex = index,
          onReorderItem: _noopReorder,
        ),
      );

      final removeButtons = find.byTooltip('Remove file');
      expect(removeButtons, findsNWidgets(2));

      await tester.tap(removeButtons.at(1));

      expect(removedIndex, 1);
    });

    testWidgets('uses custom max cross axis extent', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 500,
          child: ImageFilePickerGrid(
            filePaths: ['one.png', 'two.png'],
            maxCrossAxisExtent: 100,
            onRemoveFile: _noopRemove,
            onReorderItem: _noopReorder,
          ),
        ),
      );

      final firstTile = tester.getSize(find.byType(ImageFileThumbnail).first);

      expect(firstTile.width, greaterThan(0));
      expect(firstTile.height, greaterThan(0));
    });

    testWidgets('renders file name without directory', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: ['photo.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      expect(find.text('photo.png'), findsOneWidget);
    });

    testWidgets('renders Windows-style file name', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: [r'C:\Images\photo.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      expect(find.text('photo.png'), findsOneWidget);
    });

    testWidgets('does not reorder when dropped onto the same tile', (
      tester,
    ) async {
      final reorderCalls = <List<int>>[];

      await pumpApp(
        tester,
        ImageFilePickerGrid(
          filePaths: const ['one.png', 'two.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: (oldIndex, newIndex) {
            reorderCalls.add([oldIndex, newIndex]);
          },
        ),
      );

      final target = find.byKey(const ValueKey('image-grid-one.png'));

      final dragTarget = tester.widget<DragTarget<int>>(target);

      final details = DragTargetDetails<int>(data: 0, offset: Offset.zero);

      dragTarget.onAcceptWithDetails?.call(details);

      expect(reorderCalls, isEmpty);
    });

    testWidgets('reorders upward with target insertion index', (tester) async {
      final reorderCalls = <List<int>>[];

      await pumpApp(
        tester,
        ImageFilePickerGrid(
          filePaths: const ['one.png', 'two.png', 'three.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: (oldIndex, newIndex) {
            reorderCalls.add([oldIndex, newIndex]);
          },
        ),
      );

      final target = find.byKey(const ValueKey('image-grid-one.png'));

      final dragTarget = tester.widget<DragTarget<int>>(target);

      dragTarget.onAcceptWithDetails?.call(
        DragTargetDetails<int>(data: 2, offset: Offset.zero),
      );

      expect(reorderCalls, [
        [2, 0],
      ]);
    });

    testWidgets('reorders downward with adjusted insertion index', (
      tester,
    ) async {
      final reorderCalls = <List<int>>[];

      await pumpApp(
        tester,
        ImageFilePickerGrid(
          filePaths: const ['one.png', 'two.png', 'three.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: (oldIndex, newIndex) {
            reorderCalls.add([oldIndex, newIndex]);
          },
        ),
      );

      final target = find.byKey(const ValueKey('image-grid-three.png'));

      final dragTarget = tester.widget<DragTarget<int>>(target);

      dragTarget.onAcceptWithDetails?.call(
        DragTargetDetails<int>(data: 0, offset: Offset.zero),
      );

      expect(reorderCalls, [
        [0, 3],
      ]);
    });

    testWidgets('drag target does not accept its own item', (tester) async {
      await pumpApp(
        tester,
        const ImageFilePickerGrid(
          filePaths: ['one.png', 'two.png'],
          onRemoveFile: _noopRemove,
          onReorderItem: _noopReorder,
        ),
      );

      final target = find.byKey(const ValueKey('image-grid-one.png'));

      final dragTarget = tester.widget<DragTarget<int>>(target);

      expect(
        dragTarget.onWillAcceptWithDetails!(
          DragTargetDetails<int>(data: 0, offset: Offset.zero),
        ),
        isFalse,
      );

      expect(
        dragTarget.onWillAcceptWithDetails!(
          DragTargetDetails<int>(data: 1, offset: Offset.zero),
        ),
        isTrue,
      );
    });
  });
}

void _noopRemove(int index) {}

void _noopReorder(int oldIndex, int newIndex) {}
