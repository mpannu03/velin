import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:velin/core/platform/platform.dart';

import 'app_effect.dart';
import 'app_effect_controller.dart';

class AppEffectListener extends StatefulWidget {
  const AppEffectListener({
    super.key,
    required this.controller,
    required this.child,
  });

  final AppEffectController controller;
  final Widget child;

  @override
  State<AppEffectListener> createState() => _AppEffectListenerState();
}

class _AppEffectListenerState extends State<AppEffectListener> {
  StreamSubscription<AppEffect>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = widget.controller.effects.listen(_handleEffect);
  }

  void _handleEffect(AppEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NotificationEffect(:final message, :final type):
        _showNotification(message, type: type);
    }
  }

  void _showNotification(String message, {required NotificationType type}) {
    switch (appPlatform) {
      case AppPlatform.mobile:
        _showSnackBar(message, type: type);
      case AppPlatform.desktop:
        _showDesktopNotification(message, type: type);
    }
  }

  void _showSnackBar(String message, {required NotificationType type}) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _showDesktopNotification(
    String message, {
    required NotificationType type,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 360,
        ),
      );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
