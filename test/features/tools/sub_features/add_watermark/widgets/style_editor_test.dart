import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('StyleEditor', () {
    Widget buildEditor({
      double opacity = 0.5,
      double rotation = 0,
      WatermarkPosition position = WatermarkPosition.center,
      double xOffset = 0,
      double yOffset = 0,
      WatermarkLayer layer = WatermarkLayer.foreground,
      ValueChanged<double>? onOpacityChanged,
      ValueChanged<double>? onRotationChanged,
      ValueChanged<WatermarkPosition>? onPositionChanged,
      ValueChanged<double>? onXOffsetChanged,
      ValueChanged<double>? onYOffsetChanged,
      ValueChanged<WatermarkLayer>? onLayerChanged,
    }) {
      return StyleEditor(
        opacity: opacity,
        rotation: rotation,
        position: position,
        xOffset: xOffset,
        yOffset: yOffset,
        layer: layer,
        onOpacityChanged: onOpacityChanged ?? (_) {},
        onRotationChanged: onRotationChanged ?? (_) {},
        onPositionChanged: onPositionChanged ?? (_) {},
        onXOffsetChanged: onXOffsetChanged ?? (_) {},
        onYOffsetChanged: onYOffsetChanged ?? (_) {},
        onLayerChanged: onLayerChanged ?? (_) {},
      );
    }

    testWidgets('renders all style controls', (tester) async {
      await pumpApp(tester, buildEditor());

      expect(
        find.byKey(const ValueKey('add-watermark-opacity')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('add-watermark-rotation')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('add-watermark-offset-x')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('add-watermark-offset-y')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('add-watermark-layer')), findsOneWidget);

      expect(find.byType(ChoiceChip), findsNWidgets(5));
    });

    testWidgets('configures opacity slider', (tester) async {
      await pumpApp(tester, buildEditor(opacity: 0.75));

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('add-watermark-opacity')),
      );

      expect(slider.value, 0.75);
      expect(slider.min, AddWatermarkToolInput.minOpacity);
      expect(slider.max, AddWatermarkToolInput.maxOpacity);
      expect(slider.divisions, 19);

      // displayValue is rendered as the right-hand readout Text.
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('configures rotation slider', (tester) async {
      await pumpApp(tester, buildEditor(rotation: -30));

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('add-watermark-rotation')),
      );

      expect(slider.value, -30);
      expect(slider.min, AddWatermarkToolInput.minRotation);
      expect(slider.max, AddWatermarkToolInput.maxRotation);
      expect(slider.divisions, 72);

      expect(find.text('-30°'), findsOneWidget);
    });

    testWidgets('configures offset sliders', (tester) async {
      await pumpApp(tester, buildEditor(xOffset: 12, yOffset: -18));

      final xSlider = tester.widget<Slider>(
        find.byKey(const ValueKey('add-watermark-offset-x')),
      );
      final ySlider = tester.widget<Slider>(
        find.byKey(const ValueKey('add-watermark-offset-y')),
      );

      expect(xSlider.value, 12);
      expect(xSlider.min, AddWatermarkToolInput.minOffset);
      expect(xSlider.max, AddWatermarkToolInput.maxOffset);
      expect(xSlider.divisions, 60);
      expect(find.text('12'), findsOneWidget);

      expect(ySlider.value, -18);
      expect(ySlider.min, AddWatermarkToolInput.minOffset);
      expect(ySlider.max, AddWatermarkToolInput.maxOffset);
      expect(ySlider.divisions, 60);
      expect(find.text('-18'), findsOneWidget);
    });

    testWidgets('forwards slider changes', (tester) async {
      double? opacity;
      double? rotation;
      double? xOffset;
      double? yOffset;

      await pumpApp(
        tester,
        buildEditor(
          onOpacityChanged: (v) => opacity = v,
          onRotationChanged: (v) => rotation = v,
          onXOffsetChanged: (v) => xOffset = v,
          onYOffsetChanged: (v) => yOffset = v,
        ),
      );

      tester
          .widget<Slider>(find.byKey(const ValueKey('add-watermark-opacity')))
          .onChanged!(0.8);

      tester
          .widget<Slider>(find.byKey(const ValueKey('add-watermark-rotation')))
          .onChanged!(90);

      tester
          .widget<Slider>(find.byKey(const ValueKey('add-watermark-offset-x')))
          .onChanged!(15);

      tester
          .widget<Slider>(find.byKey(const ValueKey('add-watermark-offset-y')))
          .onChanged!(-20);

      expect(opacity, 0.8);
      expect(rotation, 90);
      expect(xOffset, 15);
      expect(yOffset, -20);
    });

    testWidgets('selects the current position', (tester) async {
      await pumpApp(
        tester,
        buildEditor(position: WatermarkPosition.bottomRight),
      );

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));

      expect(chips.where((chip) => chip.selected), hasLength(1));
    });

    testWidgets('forwards position changes', (tester) async {
      WatermarkPosition? selectedPosition;

      await pumpApp(
        tester,
        buildEditor(onPositionChanged: (v) => selectedPosition = v),
      );

      final context = tester.element(find.byType(StyleEditor));

      await tester.tap(find.text(context.l10n.toolsWatermarkPositionTopLeft));
      await tester.pump();

      expect(selectedPosition, WatermarkPosition.topLeft);
    });

    testWidgets('configures and forwards layer changes', (tester) async {
      WatermarkLayer? selectedLayer;

      await pumpApp(
        tester,
        buildEditor(
          layer: WatermarkLayer.background,
          onLayerChanged: (v) => selectedLayer = v,
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<WatermarkLayer>>(
        find.byKey(const ValueKey('add-watermark-layer')),
      );

      expect(segmentedButton.selected, {WatermarkLayer.background});

      final context = tester.element(find.byType(StyleEditor));

      await tester.tap(find.text(context.l10n.toolsWatermarkLayerForeground));
      await tester.pump();

      expect(selectedLayer, WatermarkLayer.foreground);
    });
  });
}
