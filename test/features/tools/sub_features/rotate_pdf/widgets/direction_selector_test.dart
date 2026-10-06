import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('DirectionSelector', () {
    testWidgets('renders all supported directions', (tester) async {
      await pumpApp(
        tester,
        DirectionSelector(
          direction: RotatePdfDirection.clockwise90,
          onDirectionChanged: (_) {},
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsRotateDirection90), findsOneWidget);
      expect(find.text(l10n.toolsRotateDirection180), findsOneWidget);
      expect(find.text(l10n.toolsRotateDirection270), findsOneWidget);
    });

    testWidgets('selects the current direction', (tester) async {
      await pumpApp(
        tester,
        DirectionSelector(
          direction: RotatePdfDirection.counterClockwise90,
          onDirectionChanged: (_) {},
        ),
      );

      final segmentedButton = tester
          .widget<SegmentedButton<RotatePdfDirection>>(
            find.byType(SegmentedButton<RotatePdfDirection>),
          );

      expect(segmentedButton.selected, {RotatePdfDirection.counterClockwise90});
    });

    testWidgets('forwards direction changes', (tester) async {
      RotatePdfDirection? selectedDirection;

      await pumpApp(
        tester,
        DirectionSelector(
          direction: RotatePdfDirection.clockwise90,
          onDirectionChanged: (direction) {
            selectedDirection = direction;
          },
        ),
      );

      final segmentedButton = tester
          .widget<SegmentedButton<RotatePdfDirection>>(
            find.byType(SegmentedButton<RotatePdfDirection>),
          );

      segmentedButton.onSelectionChanged?.call({RotatePdfDirection.upsideDown});

      expect(selectedDirection, RotatePdfDirection.upsideDown);
    });
  });
}
