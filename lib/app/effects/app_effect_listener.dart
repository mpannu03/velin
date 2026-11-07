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
    this.navigatorKey,
  });

  final AppEffectController controller;
  final Widget child;

  /// The app's root navigator, used to show dialogs. Falls back to this
  /// widget's own context (enough for tests that wrap it in a Navigator).
  final GlobalKey<NavigatorState>? navigatorKey;

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

      case ConfirmationEffect():
        unawaited(_showConfirmation(effect));
    }
  }

  Future<void> _showConfirmation(ConfirmationEffect effect) async {
    // This widget sits above the router's Navigator, so dialogs must be
    // shown through the Navigator's own context.
    final dialogContext = widget.navigatorKey?.currentContext ?? context;
    final l10n = AppLocalizations.of(dialogContext);

    if (l10n == null || Navigator.maybeOf(dialogContext) == null) {
      effect.completer.complete(false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        return AlertDialog(
          title: Text(effect.title(l10n)),
          content: Text(effect.message(l10n)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: effect.isDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(effect.confirmLabel(l10n)),
            ),
          ],
        );
      },
    );

    effect.completer.complete(confirmed ?? false);
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
