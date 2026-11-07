import 'dart:async';

import 'package:velin/l10n/app_localizations.dart';

/// Text that is resolved against the current locale when it is shown.
///
/// Blocs describe *what* to say (`(l10n) => l10n.toolsMergeSuccess`) without
/// depending on [AppLocalizations] themselves.
typedef LocalizedMessage = String Function(AppLocalizations l10n);

sealed class AppEffect {
  const AppEffect();
}

final class NotificationEffect extends AppEffect {
  const NotificationEffect({required this.message, required this.type});

  final LocalizedMessage message;
  final NotificationType type;
}

enum NotificationType { info, success, warning, error }

/// Asks the user a yes/no question; [completer] receives the answer.
final class ConfirmationEffect extends AppEffect {
  ConfirmationEffect({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = false,
  });

  final LocalizedMessage title;
  final LocalizedMessage message;
  final LocalizedMessage confirmLabel;

  /// Styles the confirm button as a destructive action.
  final bool isDestructive;

  final Completer<bool> completer = Completer<bool>();
}
