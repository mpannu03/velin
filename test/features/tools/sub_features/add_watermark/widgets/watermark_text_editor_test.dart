import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('TextWatermarkEditor', () {
    testWidgets('renders text field with initial text', (tester) async {
      await pumpApp(
        tester,
        TextWatermarkEditor(
          text: 'Confidential',
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
        ),
      );

      final textField = tester.widget<TextField>(
        find.byKey(const ValueKey('add-watermark-text')),
      );

      expect(textField.controller!.text, 'Confidential');
    });

    testWidgets('forwards text changes', (tester) async {
      String? changedText;

      await pumpApp(
        tester,
        TextWatermarkEditor(
          text: '',
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          onTextChanged: (value) => changedText = value,
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('add-watermark-text')),
        'DRAFT',
      );

      expect(changedText, 'DRAFT');
    });

    testWidgets('updates text field when external text changes', (
      tester,
    ) async {
      Widget buildEditor(String text) {
        return TextWatermarkEditor(
          text: text,
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
        );
      }

      await pumpApp(tester, buildEditor('First'));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: buildEditor('Second')),
        ),
      );

      final textField = tester.widget<TextField>(
        find.byKey(const ValueKey('add-watermark-text')),
      );

      expect(textField.controller!.text, 'Second');
    });

    testWidgets('passes font value and callback to FontDropdown', (
      tester,
    ) async {
      String? changedFont;

      await pumpApp(
        tester,
        TextWatermarkEditor(
          text: 'Draft',
          fontName: 'Helvetica',
          fontSize: 24,
          colorHex: '#000000',
          onTextChanged: (_) {},
          onFontNameChanged: (value) => changedFont = value,
          onFontSizeChanged: (_) {},
          onColorHexChanged: (_) {},
        ),
      );

      final dropdown = tester.widget<FontDropdown>(find.byType(FontDropdown));

      expect(dropdown.fontName, 'Helvetica');

      dropdown.onFontNameChanged('Times New Roman');

      expect(changedFont, 'Times New Roman');
    });

    testWidgets('passes font size configuration and callback to slider', (
      tester,
    ) async {
      double? changedSize;

      await pumpApp(
        tester,
        TextWatermarkEditor(
          text: 'Draft',
          fontName: null,
          fontSize: 24,
          colorHex: '#000000',
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (value) => changedSize = value,
          onColorHexChanged: (_) {},
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('add-watermark-font-size')),
      );

      expect(slider.value, 24);
      expect(slider.min, AddWatermarkToolInput.minFontSize.toDouble());
      expect(slider.max, AddWatermarkToolInput.maxFontSize.toDouble());
      expect(
        slider.divisions,
        AddWatermarkToolInput.maxFontSize - AddWatermarkToolInput.minFontSize,
      );

      expect(find.text('24'), findsOneWidget);

      slider.onChanged!(36);

      expect(changedSize, 36);
    });

    testWidgets('passes color value and callback to ColorPicker', (
      tester,
    ) async {
      String? changedColor;

      await pumpApp(
        tester,
        TextWatermarkEditor(
          text: 'Draft',
          fontName: null,
          fontSize: 24,
          colorHex: '#FF0000',
          onTextChanged: (_) {},
          onFontNameChanged: (_) {},
          onFontSizeChanged: (_) {},
          onColorHexChanged: (value) => changedColor = value,
        ),
      );

      final colorPicker = tester.widget<ColorPicker>(find.byType(ColorPicker));

      expect(colorPicker.colorHex, '#FF0000');

      colorPicker.onColorHexChanged('#00FF00');

      expect(changedColor, '#00FF00');
    });
  });
}
