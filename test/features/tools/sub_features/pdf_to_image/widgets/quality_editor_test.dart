import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ImageQualityEditor', () {
    testWidgets('renders quality label and current value', (tester) async {
      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 75,
          onQualityChanged: (_) {},
          supportsQuality: true,
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsPdfToImageQualityLabel), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('renders quality helper text', (tester) async {
      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 75,
          onQualityChanged: (_) {},
          supportsQuality: true,
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsPdfToImageQualityHelper), findsOneWidget);
    });

    testWidgets('configures slider with current quality', (tester) async {
      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 80,
          onQualityChanged: (_) {},
          supportsQuality: true,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('pdf-to-image-quality')),
      );

      expect(slider.value, 80);
      expect(slider.min, 1);
      expect(slider.max, 100);
      expect(slider.divisions, 99);
      expect(slider.onChanged, isNotNull);
    });

    testWidgets('forwards rounded slider value', (tester) async {
      int? selectedQuality;

      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 75,
          onQualityChanged: (value) {
            selectedQuality = value;
          },
          supportsQuality: true,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('pdf-to-image-quality')),
      );

      slider.onChanged?.call(82.6);

      expect(selectedQuality, 83);
    });

    testWidgets('disables slider when quality is not supported', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 75,
          onQualityChanged: (_) {},
          supportsQuality: false,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('pdf-to-image-quality')),
      );

      expect(slider.value, 75);
      expect(slider.onChanged, isNull);
    });

    testWidgets('does not invoke callback when quality is unsupported', (
      tester,
    ) async {
      var callbackCalled = false;

      await pumpApp(
        tester,
        ImageQualityEditor(
          quality: 75,
          onQualityChanged: (_) {
            callbackCalled = true;
          },
          supportsQuality: false,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('pdf-to-image-quality')),
      );

      expect(slider.onChanged, isNull);
      expect(callbackCalled, isFalse);
    });
  });
}
