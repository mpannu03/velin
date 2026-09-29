import 'package:flutter_test/flutter_test.dart';
import 'package:velin/app/effects/effects.dart';

void main() {
  group('AppEffectController', () {
    late AppEffectController controller;

    setUp(() {
      controller = AppEffectController();
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('emits notification effect', () async {
      final future = controller.effects.first;

      controller.notifyUser(
        message: 'Something went wrong',
        type: NotificationType.error,
      );

      final effect = await future;

      expect(effect, isA<NotificationEffect>());

      final notification = effect as NotificationEffect;

      expect(notification.message, 'Something went wrong');
      expect(notification.type, NotificationType.error);
    });
  });
}