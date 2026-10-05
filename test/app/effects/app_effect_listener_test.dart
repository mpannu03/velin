import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/effects/effects.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppEffectListener', () {
    late AppEffectController controller;

    setUp(() {
      controller = AppEffectController();
    });

    tearDown(() async {
      await controller.dispose();
    });

    testWidgets('shows notification when effect is emitted', (tester) async {
      await pumpApp(
        tester,
        AppEffectListener(controller: controller, child: const SizedBox()),
      );

      controller.notifyUser(
        message: 'Could not open document',
        type: NotificationType.error,
      );

      await tester.pump();

      expect(find.text('Could not open document'), findsOneWidget);
    });

    testWidgets('does not show notification before effect is emitted', (
      tester,
    ) async {
      await pumpApp(
        tester,
        AppEffectListener(controller: controller, child: const SizedBox()),
      );

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
