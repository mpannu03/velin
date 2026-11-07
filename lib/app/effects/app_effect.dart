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
