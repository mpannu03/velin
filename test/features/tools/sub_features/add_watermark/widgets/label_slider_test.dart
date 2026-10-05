import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/sub_features/add_watermark/add_watermark.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('LabeledSlider', () {
    testWidgets('renders label and display value', (tester) async {
      await pumpApp(
        tester,
        const LabeledSlider(
          label: 'Width',
          value: 50,
          min: 10,
          max: 100,
          divisions: 18,
          displayValue: '50%',
          sliderKey: ValueKey('slider'),
          onChanged: _noop,
        ),
      );

      expect(find.text('Width'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('passes slider configuration to Slider', (tester) async {
      await pumpApp(
        tester,
        const LabeledSlider(
          label: 'Width',
          value: 50,
          min: 10,
          max: 100,
          divisions: 18,
          displayValue: '50%',
          sliderKey: ValueKey('slider'),
          onChanged: _noop,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('slider')),
      );

      expect(slider.min, 10);
      expect(slider.max, 100);
      expect(slider.divisions, 18);
      expect(slider.value, 50);
      expect(slider.label, '50%');
    });

    testWidgets('clamps value below minimum', (tester) async {
      await pumpApp(
        tester,
        const LabeledSlider(
          label: 'Width',
          value: 5,
          min: 10,
          max: 100,
          divisions: 18,
          displayValue: '5%',
          sliderKey: ValueKey('slider'),
          onChanged: _noop,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('slider')),
      );

      expect(slider.value, 10);
    });

    testWidgets('clamps value above maximum', (tester) async {
      await pumpApp(
        tester,
        const LabeledSlider(
          label: 'Width',
          value: 120,
          min: 10,
          max: 100,
          divisions: 18,
          displayValue: '120%',
          sliderKey: ValueKey('slider'),
          onChanged: _noop,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('slider')),
      );

      expect(slider.value, 100);
    });

    testWidgets('forwards slider changes', (tester) async {
      double? changedValue;

      await pumpApp(
        tester,
        LabeledSlider(
          label: 'Width',
          value: 50,
          min: 10,
          max: 100,
          divisions: 18,
          displayValue: '50%',
          sliderKey: const ValueKey('slider'),
          onChanged: (value) => changedValue = value,
        ),
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('slider')),
      );

      slider.onChanged?.call(75);

      expect(changedValue, 75);
    });
  });
}

void _noop(double value) {}
