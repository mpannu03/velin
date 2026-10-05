import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('FontDropdown', () {
    testWidgets('renders all supported fonts', (tester) async {
      await pumpApp(
        tester,
        const FontDropdown(fontName: null, onFontNameChanged: _noop),
      );

      // Open the dropdown so its items are built into the tree.
      await tester.tap(find.byKey(const ValueKey('add-watermark-font')));
      await tester.pumpAndSettle();

      for (final font in AddWatermarkToolInput.supportedFonts) {
        final context = tester.element(find.byType(FontDropdown));
        final label = font ?? context.l10n.toolsWatermarkFontDefault;

        expect(
          find.text(label),
          findsWidgets, // at least one — the menu item, possibly also the closed button
          reason: 'Expected dropdown to contain "$label".',
        );
      }
    });

    testWidgets('uses the provided font as the initial value', (tester) async {
      const fontName = 'Helvetica';

      await pumpApp(
        tester,
        const FontDropdown(fontName: fontName, onFontNameChanged: _noop),
      );

      final dropdown = tester.widget<DropdownButtonFormField<String?>>(
        find.byKey(const ValueKey('add-watermark-font')),
      );

      expect(dropdown.initialValue, fontName);
    });

    testWidgets('reports the selected font', (tester) async {
      String? selectedFont;

      await pumpApp(
        tester,
        FontDropdown(
          fontName: null,
          onFontNameChanged: (value) => selectedFont = value,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('add-watermark-font')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Helvetica').last);
      await tester.pump();

      expect(selectedFont, 'Helvetica');
    });

    testWidgets('reports null when the default font is selected', (
      tester,
    ) async {
      String? selectedFont = 'Helvetica';

      await pumpApp(
        tester,
        FontDropdown(
          fontName: 'Helvetica',
          onFontNameChanged: (value) => selectedFont = value,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('add-watermark-font')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(FontDropdown));

      await tester.tap(find.text(context.l10n.toolsWatermarkFontDefault).last);
      await tester.pump();

      expect(selectedFont, isNull);
    });
  });
}

void _noop(String? value) {}
