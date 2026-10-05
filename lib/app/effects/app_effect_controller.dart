import 'dart:async';

import 'app_effect.dart';

class AppEffectController {
  AppEffectController();

  final StreamController<AppEffect> _controller =
      StreamController<AppEffect>.broadcast();

  Stream<AppEffect> get effects => _controller.stream;

  void notifyUser({required String message, required NotificationType type}) {
    _controller.add(NotificationEffect(message: message, type: type));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
