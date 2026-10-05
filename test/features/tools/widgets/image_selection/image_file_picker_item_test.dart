import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ImageFileThumbnail', () {
    testWidgets('shows fallback when image cannot be decoded', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await pumpApp(
          tester,
          const SizedBox(
            width: 100,
            height: 100,
            child: ImageFileThumbnail(
              filePath: '/path/that/does/not/exist/image.png',
            ),
          ),
        );
        // Let FileImage's readAsBytes attempt complete.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.broken_image_outlined),
        findsOneWidget,
      );
    });

    testWidgets('uses supplied border radius', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 100,
          height: 100,
          child: ImageFileThumbnail(
            filePath: '/path/that/does/not/exist/image.png',
            borderRadius: 20,
          ),
        ),
      );

      final clip = tester.widget<ClipRRect>(
        find.byType(ClipRRect),
      );

      expect(
        clip.borderRadius,
        BorderRadius.circular(20),
      );
    });

    testWidgets('uses default border radius', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 100,
          height: 100,
          child: ImageFileThumbnail(
            filePath: '/path/that/does/not/exist/image.png',
          ),
        ),
      );

      final clip = tester.widget<ClipRRect>(
        find.byType(ClipRRect),
      );

      expect(
        clip.borderRadius,
        BorderRadius.circular(8),
      );
    });
  });

  group('ImageOrderBadge', () {
    testWidgets('shows the supplied index', (tester) async {
      await pumpApp(
        tester,
        const ImageOrderBadge(index: 3),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows zero when supplied', (tester) async {
      await pumpApp(
        tester,
        const ImageOrderBadge(index: 0),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows negative index when supplied', (tester) async {
      await pumpApp(
        tester,
        const ImageOrderBadge(index: -1),
      );

      expect(find.text('-1'), findsOneWidget);
    });
  });

  group('ImageFilePickerItem', () {
    testWidgets('shows file name and directory', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/images/photo.png',
          onRemove: () {},
        ),
      );

      expect(find.text('photo.png'), findsOneWidget);
      expect(find.text('/documents/images'), findsOneWidget);
    });

    testWidgets('supports Windows paths', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: r'C:\Documents\Images\photo.png',
          onRemove: () {},
        ),
      );

      expect(find.text('photo.png'), findsOneWidget);
      expect(find.text(r'C:\Documents\Images'), findsOneWidget);
    });

    testWidgets('does not show directory for a bare filename', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: 'photo.png',
          onRemove: () {},
        ),
      );

      expect(find.text('photo.png'), findsOneWidget);
      expect(find.text('/documents'), findsNothing);
    });

    testWidgets('shows index when provided', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
          index: 4,
          onRemove: () {},
        ),
      );

      expect(find.byType(ImageOrderBadge), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('hides index when not provided', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
          onRemove: () {},
        ),
      );

      expect(find.byType(ImageOrderBadge), findsNothing);
    });

    testWidgets('shows drag handle when provided', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
          onRemove: () {},
          dragHandle: const Icon(Icons.drag_indicator),
        ),
      );

      expect(
        find.byIcon(Icons.drag_indicator),
        findsOneWidget,
      );
    });

    testWidgets('hides drag handle when not provided', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
          onRemove: () {},
        ),
      );

      expect(
        find.byIcon(Icons.drag_indicator),
        findsNothing,
      );
    });

    testWidgets('shows image thumbnail', (tester) async {
      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
          onRemove: () {},
        ),
      );

      expect(
        find.byType(ImageFileThumbnail),
        findsOneWidget,
      );
    });

    testWidgets('calls onRemove when remove button is tapped', (
      tester,
    ) async {
      var removed = false;

      await pumpApp(
        tester,
        ImageFilePickerItem(
          filePath: '/documents/photo.png',
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