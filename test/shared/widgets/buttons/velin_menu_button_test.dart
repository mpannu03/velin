import 'package:flutter_test/flutter_test.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('VelinMenuButton', () {
    testWidgets('shows label', (tester) async {
      await pumpApp(tester, VelinMenuButton(label: 'Open', onPressed: () {}));

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        VelinMenuButton(label: 'Open', onPressed: () => pressed = true),
      );

      await tester.tap(find.text('Open'));

      expect(pressed, isTrue);
    });
  });
}
