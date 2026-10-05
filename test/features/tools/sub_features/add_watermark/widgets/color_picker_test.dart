import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ColorPicker', () {
    testWidgets('renders all common color swatches', (tester) async {
      await pumpApp(
        tester,
        ColorPicker(colorHex: '#FF0000', onColorHexChanged: (_) {}),
      );

      expect(
        find.byType(VColorSwatch),
        findsNWidgets(AddWatermarkToolInput.commonColors.length),
      );
    });

    testWidgets('shows the initial color in the text field', (tester) async {
      await pumpApp(
        tester,
        ColorPicker(colorHex: '#123456', onColorHexChanged: (_) {}),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('add-watermark-color-hex')),
      );

      expect(field.controller?.text, '#123456');
    });

    testWidgets('selecting a swatch reports its color', (tester) async {
      String? selectedColor;

      await pumpApp(
        tester,
        ColorPicker(
          colorHex: '#000000',
          onColorHexChanged: (value) => selectedColor = value,
        ),
      );

      final expectedColor = AddWatermarkToolInput.commonColors.first;

      await tester.tap(find.byType(VColorSwatch).first);

      expect(selectedColor, expectedColor);
    });

    testWidgets('submitting the hex field reports the entered color', (
      tester,
    ) async {
      String? submittedColor;

      await pumpApp(
        tester,
        ColorPicker(
          colorHex: '#000000',
          onColorHexChanged: (value) => submittedColor = value,
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('add-watermark-color-hex')),
        '#123456',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedColor, '#123456');
    });

    testWidgets('tapping outside the hex field reports the current color', (
      tester,
    ) async {
      String? submittedColor;

      await pumpApp(
        tester,
        ColorPicker(
          colorHex: '#000000',
          onColorHexChanged: (value) => submittedColor = value,
        ),
      );

      final field = find.byKey(const ValueKey('add-watermark-color-hex'));

      await tester.enterText(field, '#123456');
      await tester.tapAt(const Offset(10, 10));

      expect(submittedColor, '#123456');
    });

    testWidgets('updates the text field when colorHex changes', (tester) async {
      await pumpApp(
        tester,
        ColorPicker(colorHex: '#123456', onColorHexChanged: (_) {}),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: ColorPicker(colorHex: '#ABCDEF', onColorHexChanged: _noop),
          ),
        ),
      );

      await tester.pump();

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('add-watermark-color-hex')),
      );

      expect(field.controller?.text, '#ABCDEF');
    });

    testWidgets('marks a swatch selected case-insensitively', (tester) async {
      final commonColor = AddWatermarkToolInput.commonColors.first;

      await pumpApp(
        tester,
        ColorPicker(
          colorHex: commonColor.toLowerCase(),
          onColorHexChanged: (_) {},
        ),
      );

      final swatches = tester.widgetList<VColorSwatch>(
        find.byType(VColorSwatch),
      );

      final selected = swatches.where((swatch) => swatch.isSelected);

      expect(selected, hasLength(1));
      expect(selected.first.hex.toUpperCase(), commonColor.toUpperCase());
    });
  });
}

void _noop(String value) {}
