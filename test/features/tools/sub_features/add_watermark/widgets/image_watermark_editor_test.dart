import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ImageWatermarkEditor', () {
    testWidgets('shows empty state when no image is selected', (tester) async {
      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: null,
          imageWidthPercent: 40,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      expect(find.byType(ImageEmptyState), findsOneWidget);
      expect(find.byType(SelectedImageRow), findsNothing);
    });

    testWidgets('shows empty state when image path is empty', (tester) async {
      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: '   ',
          imageWidthPercent: 40,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      expect(find.byType(ImageEmptyState), findsOneWidget);
      expect(find.byType(SelectedImageRow), findsNothing);
    });

    testWidgets('shows selected image when an image path is provided', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: '/images/watermark.png',
          imageWidthPercent: 40,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      expect(find.byType(SelectedImageRow), findsOneWidget);
      expect(find.byType(ImageEmptyState), findsNothing);
    });

    testWidgets('forwards pick callback when no image is selected', (
      tester,
    ) async {
      var picked = false;

      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: null,
          imageWidthPercent: 40,
          onPickWatermarkImage: () => picked = true,
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      await tester.tap(find.byKey(const ValueKey('add-watermark-pick-image')));
      await tester.pump();

      expect(picked, isTrue);
    });

    testWidgets('forwards replace and remove callbacks', (tester) async {
      var replaced = false;
      var removed = false;

      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: '/images/watermark.png',
          imageWidthPercent: 40,
          onPickWatermarkImage: () => replaced = true,
          onClearWatermarkImage: () => removed = true,
          onImageWidthPercentChanged: (_) {},
        ),
      );

      await tester.tap(find.byKey(const ValueKey('selected-image-replace')));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('selected-image-remove')));
      await tester.pump();

      expect(replaced, isTrue);
      expect(removed, isTrue);
    });

    testWidgets('passes image width to the slider', (tester) async {
      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: null,
          imageWidthPercent: 65,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      final slider = tester.widget<LabeledSlider>(find.byType(LabeledSlider));

      expect(slider.value, 65);
      expect(slider.min, AddWatermarkToolInput.minImageWidthPercent);
      expect(slider.max, AddWatermarkToolInput.maxImageWidthPercent);
      expect(slider.divisions, 19);
      expect(slider.displayValue, '65%');
    });

    testWidgets('forwards image width changes', (tester) async {
      double? width;

      await pumpApp(
        tester,
        ImageWatermarkEditor(
          imageFilePath: null,
          imageWidthPercent: 40,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (value) => width = value,
        ),
      );

      final slider = tester.widget<LabeledSlider>(find.byType(LabeledSlider));

      slider.onChanged(72);

      expect(width, 72);
    });
  });
}
