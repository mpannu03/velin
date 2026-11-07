import 'package:flutter_test/flutter_test.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppEffectController', () {
    late AppEffectController controller;
    late List<NotificationEffect> effects;

    setUp(() {
      controller = AppEffectController();
      effects = [];
      controller.effects.listen((e) => effects.add(e as NotificationEffect));
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('emits notification effect', () async {
      controller.notifyUser(
        message: (l10n) => l10n.errorDiskFull,
        type: NotificationType.error,
      );

      await pumpEventQueue();

      expect(effects.single.message(testL10n), testL10n.errorDiskFull);
      expect(effects.single.type, NotificationType.error);
    });

    test('notifyFailure shows the failure message as an error', () async {
      controller.notifyFailure(const FileInUseFailure());

      await pumpEventQueue();

      expect(effects.single.message(testL10n), testL10n.errorFileInUse);
      expect(effects.single.type, NotificationType.error);
    });

    test(
      'notifyFailure prefers the fallback for unexpected failures',
      () async {
        controller.notifyFailure(
          const UnexpectedFailure(),
          fallback: (l10n) => l10n.toolsMergeFailed,
        );

        await pumpEventQueue();

        expect(effects.single.message(testL10n), testL10n.toolsMergeFailed);
      },
    );

    test('notifyFailure ignores the fallback for expected failures', () async {
      controller.notifyFailure(
        const DiskFullFailure(),
        fallback: (l10n) => l10n.toolsMergeFailed,
      );

      await pumpEventQueue();

      expect(effects.single.message(testL10n), testL10n.errorDiskFull);
    });

    test('notifyFailure stays quiet for cancellations', () async {
      controller.notifyFailure(const CancelledFailure());

      await pumpEventQueue();

      expect(effects, isEmpty);
    });
  });
}
