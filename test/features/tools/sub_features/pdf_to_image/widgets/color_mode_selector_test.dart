import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ColorModeSelector', () {
    testWidgets('renders both color mode options', (tester) async {
      await pumpApp(
        tester,
        ColorModeSelector(
          colorMode: PdfImageColorMode.color,
          onColorModeChanged: (_) {},
        ),
      );

      expect(find.text('Colour'), findsOneWidget);
      expect(find.text('Greyscale'), findsOneWidget);
    });

    testWidgets('selects the current color mode', (tester) async {
      await pumpApp(
        tester,
        ColorModeSelector(
          colorMode: PdfImageColorMode.grayscale,
          onColorModeChanged: (_) {},
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<PdfImageColorMode>>(
        find.byType(SegmentedButton<PdfImageColorMode>),
      );

      expect(segmentedButton.selected, {PdfImageColorMode.grayscale});
    });

    testWidgets('forwards color mode changes', (tester) async {
      PdfImageColorMode? selectedMode;

      await pumpApp(
        tester,
        ColorModeSelector(
          colorMode: PdfImageColorMode.color,
          onColorModeChanged: (mode) {
            selectedMode = mode;
          },
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<PdfImageColorMode>>(
        find.byType(SegmentedButton<PdfImageColorMode>),
      );

      segmentedButton.onSelectionChanged?.call({PdfImageColorMode.grayscale});

      expect(selectedMode, PdfImageColorMode.grayscale);
    });
  });
}
