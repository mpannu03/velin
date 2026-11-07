import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:velin/core/platform/platform.dart';
import 'package:velin/l10n/app_localizations.dart';

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

  static const _desktopWidth = 400.0;

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
        final l10n = AppLocalizations.of(context);
        if (l10n == null) return;

        _showNotification(message(l10n), type: type);
    }
  }

  void _showNotification(String message, {required NotificationType type}) {
    final colors = Theme.of(context).colorScheme;

    final (background, foreground, icon) = switch (type) {
      NotificationType.info => (
        colors.inverseSurface,
        colors.onInverseSurface,
        Icons.info_outline,
      ),
      NotificationType.success => (
        colors.inverseSurface,
        colors.onInverseSurface,
        Icons.check_circle_outline,
      ),
      NotificationType.warning => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        Icons.warning_amber_rounded,
      ),
      NotificationType.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
    };

    // Errors stay longer: they usually need reading, not just noticing.
    final duration = type == NotificationType.error
        ? const Duration(seconds: 8)
        : const Duration(seconds: 4);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          showCloseIcon: true,
          closeIconColor: foreground,
          width: appPlatform == AppPlatform.desktop ? _desktopWidth : null,
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
