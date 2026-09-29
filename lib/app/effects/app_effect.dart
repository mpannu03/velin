sealed class AppEffect {
  const AppEffect();
}

final class NotificationEffect extends AppEffect {
  const NotificationEffect({
    required this.message,
    required this.type,
  });

  final String message;
  final NotificationType type;
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}