import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('SelectedImageRow', () {
    testWidgets('displays the filename from a Unix path', (tester) async {
      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: '/images/watermark.png',
          onReplace: () {},
          onRemove: () {},
        ),
      );

      expect(find.text('watermark.png'), findsOneWidget);
    });

    testWidgets('displays the filename from a Windows path', (tester) async {
      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: r'C:\images\watermark.png',
          onReplace: () {},
          onRemove: () {},
        ),
      );

      expect(find.text('watermark.png'), findsOneWidget);
    });

    testWidgets('renders the image thumbnail', (tester) async {
      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: '/images/watermark.png',
          onReplace: () {},
          onRemove: () {},
        ),
      );

      final thumbnail = tester.widget<ImageFileThumbnail>(
        find.byType(ImageFileThumbnail),
      );

      expect(thumbnail.filePath, '/images/watermark.png');
    });

    testWidgets('renders replace and remove actions', (tester) async {
      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: '/images/watermark.png',
          onReplace: () {},
          onRemove: () {},
        ),
      );

      final context = tester.element(find.byType(SelectedImageRow));

      expect(
        find.text(context.l10n.toolsWatermarkImageReplace),
        findsOneWidget,
      );
      expect(find.text(context.l10n.toolsWatermarkImageRemove), findsOneWidget);
    });

    testWidgets('calls onReplace when replace is tapped', (tester) async {
      var replaced = false;

      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: '/images/watermark.png',
          onReplace: () => replaced = true,
          onRemove: () {},
        ),
      );

      await tester.tap(find.byKey(const ValueKey('selected-image-replace')));
      await tester.pump();

      expect(replaced, isTrue);
    });

    testWidgets('calls onRemove when remove is tapped', (tester) async {
      var removed = false;

      await pumpApp(
        tester,
        SelectedImageRow(
          filePath: '/images/watermark.png',
          onReplace: () {},
          onRemove: () => removed = true,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('selected-image-remove')));
      await tester.pump();

      expect(removed, isTrue);
    });
  });
}
