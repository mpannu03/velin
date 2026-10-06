import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('FormatSelector', () {
    testWidgets('renders all supported formats', (tester) async {
      await pumpApp(
        tester,
        FormatSelector(format: PdfImageFormat.png, onFormatChanged: (_) {}),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsPdfToImageFormatPng), findsOneWidget);
      expect(find.text(l10n.toolsPdfToImageFormatJpeg), findsOneWidget);
      expect(find.text(l10n.toolsPdfToImageFormatWebp), findsOneWidget);
    });

    testWidgets('renders format helper text', (tester) async {
      await pumpApp(
        tester,
        FormatSelector(format: PdfImageFormat.png, onFormatChanged: (_) {}),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsPdfToImageFormatHelper), findsOneWidget);
    });

    testWidgets('selects the current format', (tester) async {
      await pumpApp(
        tester,
        FormatSelector(format: PdfImageFormat.webp, onFormatChanged: (_) {}),
      );

      final segmentedButton = tester.widget<SegmentedButton<PdfImageFormat>>(
        find.byType(SegmentedButton<PdfImageFormat>),
      );

      expect(segmentedButton.selected, {PdfImageFormat.webp});
    });

    testWidgets('forwards format changes', (tester) async {
      PdfImageFormat? selectedFormat;

      await pumpApp(
        tester,
        FormatSelector(
          format: PdfImageFormat.png,
          onFormatChanged: (format) {
            selectedFormat = format;
          },
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<PdfImageFormat>>(
        find.byType(SegmentedButton<PdfImageFormat>),
      );

      segmentedButton.onSelectionChanged?.call({PdfImageFormat.jpeg});

      expect(selectedFormat, PdfImageFormat.jpeg);
    });
  });
}
