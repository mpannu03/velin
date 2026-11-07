import 'dart:async';

import 'package:velin/core/error/error.dart';
import 'package:velin/shared/extensions/app_failure_ext.dart';

import 'app_effect.dart';

class AppEffectController {
  AppEffectController();

  final StreamController<AppEffect> _controller =
      StreamController<AppEffect>.broadcast();

  Stream<AppEffect> get effects => _controller.stream;

  void notifyUser({
    required LocalizedMessage message,
    required NotificationType type,
  }) {
    _controller.add(NotificationEffect(message: message, type: type));
  }

  /// Tells the user about [failure].
  ///
  /// Cancellations are ignored. For unexpected failures (bugs) the specific
  /// cause means nothing to the user, so [fallback] — typically the
  /// operation's own "could not ..." message — is shown instead when given.
  void notifyFailure(AppFailure failure, {LocalizedMessage? fallback}) {
    if (failure.isCancellation) return;

    notifyUser(
      message: (l10n) => failure.userMessage(l10n, fallback: fallback),
      type: NotificationType.error,
    );
  }

  /// Asks the user to confirm an action. Resolves to `false` when declined,
  /// dismissed, or when no UI is listening (nothing to ask, so stay safe).
  Future<bool> confirm({
    required LocalizedMessage title,
    required LocalizedMessage message,
    required LocalizedMessage confirmLabel,
    bool isDestructive = false,
  }) {
    if (!_controller.hasListener) return Future.value(false);

    final effect = ConfirmationEffect(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
    );

    _controller.add(effect);

    return effect.completer.future;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
