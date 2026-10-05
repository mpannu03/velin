import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('QualityEditor', () {
    testWidgets('renders quality label and helper text', (tester) async {
      await pumpApp(
        tester,
        const QualityEditor(quality: 75, onQualityChanged: _noop),
      );

      final context = tester.element(find.byType(QualityEditor));

      expect(find.text(context.l10n.toolsCompressQualityLabel), findsOneWidget);
      expect(
        find.text(context.l10n.toolsCompressQualityHelper),
        findsOneWidget,
      );
    });

    testWidgets('renders the current quality', (tester) async {
      await pumpApp(
        tester,
        const QualityEditor(quality: 75, onQualityChanged: _noop),
      );

      expect(find.text('75'), findsOneWidget);

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('compress-pdf-quality')),
      );

      expect(slider.value, 75);
      expect(slider.label, '75');
    });

    testWidgets('configures slider from tool input limits', (tester) async {
      await pumpApp(
        tester,
        const QualityEditor(quality: 75, onQualityChanged: _noop),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('compress-pdf-quality')),
      );

      expect(slider.min, CompressPdfToolInput.minQuality.toDouble());
      expect(slider.max, CompressPdfToolInput.maxQuality.toDouble());
      expect(
        slider.divisions,
        CompressPdfToolInput.maxQuality - CompressPdfToolInput.minQuality,
      );
    });

    testWidgets('rounds slider value before forwarding callback', (
      tester,
    ) async {
      int? selectedQuality;

      await pumpApp(
        tester,
        QualityEditor(
          quality: 50,
          onQualityChanged: (value) => selectedQuality = value,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('compress-pdf-quality')),
      );

      slider.onChanged!(72.6);

      expect(selectedQuality, 73);
    });
  });
}

void _noop(int _) {}
