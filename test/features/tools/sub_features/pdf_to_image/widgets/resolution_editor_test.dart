import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ResolutionEditor', () {
    testWidgets('renders current DPI and supported options', (tester) async {
      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
          dpi: 300,
          onDpiChanged: (_) {},
        ),
      );

      expect(find.text('300 DPI'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('pdf-to-image-dpi')));
      await tester.pumpAndSettle();

      for (final dpi in PdfToImageToolInput.supportedDpi.where(
        (d) => d != 300,
      )) {
        expect(find.text('$dpi DPI'), findsOneWidget);
      }
    });

    testWidgets('renders DPI helper text', (tester) async {
      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
          dpi: 300,
          onDpiChanged: (_) {},
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsPdfToImageDpiHelper), findsOneWidget);
    });

    testWidgets('configures dropdown with current DPI', (tester) async {
      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
          dpi: 150,
          onDpiChanged: (_) {},
        ),
      );

      final dropdown = tester.widget<DropdownButton<int>>(
        find.byKey(const ValueKey('pdf-to-image-dpi')),
      );

      expect(dropdown.value, 150);
      expect(
        dropdown.items,
        hasLength(PdfToImageToolInput.supportedDpi.length),
      );
    });

    testWidgets('forwards DPI changes', (tester) async {
      int? selectedDpi;

      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
          dpi: 150,
          onDpiChanged: (value) {
            selectedDpi = value;
          },
        ),
      );

      final dropdown = tester.widget<DropdownButton<int>>(
        find.byKey(const ValueKey('pdf-to-image-dpi')),
      );

      dropdown.onChanged?.call(600);

      expect(selectedDpi, 600);
    });

    testWidgets('ignores null DPI changes', (tester) async {
      int? selectedDpi;

      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
          dpi: 150,
          onDpiChanged: (value) {
            selectedDpi = value;
          },
        ),
      );

      final dropdown = tester.widget<DropdownButton<int>>(
        find.byKey(const ValueKey('pdf-to-image-dpi')),
      );

      dropdown.onChanged?.call(null);

      expect(selectedDpi, isNull);
    });

    testWidgets('passes quality configuration to ImageQualityEditor', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 85,
          onQualityChanged: (_) {},
          supportsQuality: false,
          dpi: 300,
          onDpiChanged: (_) {},
        ),
      );

      final editor = tester.widget<ImageQualityEditor>(
        find.byType(ImageQualityEditor),
      );

      expect(editor.quality, 85);
      expect(editor.supportsQuality, isFalse);
    });

    testWidgets('forwards quality changes to ImageQualityEditor', (
      tester,
    ) async {
      int? selectedQuality;

      await pumpApp(
        tester,
        ResolutionEditor(
          quality: 85,
          onQualityChanged: (value) {
            selectedQuality = value;
          },
          supportsQuality: true,
          dpi: 300,
          onDpiChanged: (_) {},
        ),
      );

      final editor = tester.widget<ImageQualityEditor>(
        find.byType(ImageQualityEditor),
      );

      editor.onQualityChanged(90);

      expect(selectedQuality, 90);
    });
  });
}
