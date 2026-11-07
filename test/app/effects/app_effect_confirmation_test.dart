import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/effects/effects.dart';

import '../../helpers/helpers.dart';

void main() {
  late AppEffectController controller;

  setUp(() => controller = AppEffectController());
  tearDown(() => controller.dispose());

  Future<bool> ask() => controller.confirm(
    title: (l10n) => l10n.toolsOverwriteTitle,
    message: (l10n) => l10n.toolsOverwriteMessage('out.pdf'),
    confirmLabel: (l10n) => l10n.toolsOverwriteConfirm,
    isDestructive: true,
  );

  test('resolves to false when no UI is listening', () async {
    expect(await ask(), isFalse);
  });

  group('with the listener mounted', () {
    Future<void> pumpListener(WidgetTester tester) => pumpApp(
      tester,
      AppEffectListener(controller: controller, child: const SizedBox()),
    );

    testWidgets('shows a dialog and resolves true on confirm', (tester) async {
      await pumpListener(tester);

      final answer = ask();
      await tester.pumpAndSettle();

      expect(find.text(testL10n.toolsOverwriteTitle), findsOneWidget);
      expect(find.text(testL10n.toolsOverwriteMessage('out.pdf')), findsOne);

      await tester.tap(find.text(testL10n.toolsOverwriteConfirm));
      await tester.pumpAndSettle();

      expect(await answer, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('resolves false on cancel', (tester) async {
      await pumpListener(tester);

      final answer = ask();
      await tester.pumpAndSettle();

      await tester.tap(find.text(testL10n.commonCancel));
      await tester.pumpAndSettle();

      expect(await answer, isFalse);
    });
  });
}
