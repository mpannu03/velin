import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('VelinIconButton', () {
    testWidgets('shows icon and tooltip', (tester) async {
      await pumpApp(
        tester,
        VelinIconButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      final tooltip = tester.widget<Tooltip>(
        find.byType(Tooltip),
      );

      expect(tooltip.message, 'Close');
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        VelinIconButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        VelinIconButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: null,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));

      expect(pressed, isFalse);
    });
  });
}