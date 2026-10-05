import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('WatermarkContentEditor', () {
    testWidgets('shows text editor for text watermark', (tester) async {
      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.text,
          text: 'Confidential',
          imageFilePath: null,
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          imageWidthPercent: 30,
          onTypeChanged: (_) {},
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      expect(find.byType(TextWatermarkEditor), findsOneWidget);
      expect(find.byType(ImageWatermarkEditor), findsNothing);
    });

    testWidgets('shows image editor for image watermark', (tester) async {
      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.image,
          text: '',
          imageFilePath: '/images/watermark.png',
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          imageWidthPercent: 30,
          onTypeChanged: (_) {},
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      expect(find.byType(ImageWatermarkEditor), findsOneWidget);
      expect(find.byType(TextWatermarkEditor), findsNothing);
    });

    testWidgets('reflects the current watermark type', (tester) async {
      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.image,
          text: '',
          imageFilePath: null,
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          imageWidthPercent: 30,
          onTypeChanged: (_) {},
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<WatermarkType>>(
        find.byKey(const ValueKey('add-watermark-type')),
      );

      expect(segmentedButton.selected, {WatermarkType.image});
    });

    testWidgets('forwards type changes', (tester) async {
      WatermarkType? selectedType;

      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.text,
          text: 'Test',
          imageFilePath: null,
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          imageWidthPercent: 30,
          onTypeChanged: (value) => selectedType = value,
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      final context = tester.element(find.byType(WatermarkContentEditor));

      await tester.tap(find.text(context.l10n.toolsWatermarkTypeImage));
      await tester.pump();

      expect(selectedType, WatermarkType.image);
    });

    testWidgets('forwards text editor values and callbacks', (tester) async {
      String? changedText;
      String? changedFont;
      double? changedFontSize;
      String? changedColor;

      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.text,
          text: 'Test',
          imageFilePath: null,
          fontName: 'Helvetica',
          fontSize: 24,
          colorHex: '#123456',
          imageWidthPercent: 30,
          onTypeChanged: (_) {},
          onTextChanged: (value) => changedText = value,
          onFontNameChanged: (value) => changedFont = value,
          onFontSizeChanged: (value) => changedFontSize = value,
          onColorHexChanged: (value) => changedColor = value,
          onPickWatermarkImage: () {},
          onClearWatermarkImage: () {},
          onImageWidthPercentChanged: (_) {},
        ),
      );

      final editor = tester.widget<TextWatermarkEditor>(
        find.byType(TextWatermarkEditor),
      );

      expect(editor.text, 'Test');
      expect(editor.fontName, 'Helvetica');
      expect(editor.fontSize, 24);
      expect(editor.colorHex, '#123456');

      editor.onTextChanged('Updated');
      editor.onFontNameChanged('Times New Roman');
      editor.onFontSizeChanged(36);
      editor.onColorHexChanged('#ABCDEF');

      expect(changedText, 'Updated');
      expect(changedFont, 'Times New Roman');
      expect(changedFontSize, 36);
      expect(changedColor, '#ABCDEF');
    });

    testWidgets('forwards image editor values and callbacks', (tester) async {
      var picked = false;
      var cleared = false;
      double? changedWidth;

      await pumpApp(
        tester,
        WatermarkContentEditor(
          type: WatermarkType.image,
          text: '',
          imageFilePath: '/images/watermark.png',
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          imageWidthPercent: 40,
          onTypeChanged: (_) {},
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
          onPickWatermarkImage: () => picked = true,
          onClearWatermarkImage: () => cleared = true,
          onImageWidthPercentChanged: (value) => changedWidth = value,
        ),
      );

      final editor = tester.widget<ImageWatermarkEditor>(
        find.byType(ImageWatermarkEditor),
      );

      expect(editor.imageFilePath, '/images/watermark.png');
      expect(editor.imageWidthPercent, 40);

      editor.onPickWatermarkImage();
      editor.onClearWatermarkImage();
      editor.onImageWidthPercentChanged(65);

      expect(picked, isTrue);
      expect(cleared, isTrue);
      expect(changedWidth, 65);
    });
  });
}
