import 'task_status.dart';

export 'task_context.dart';
export 'task_manager.dart';
export 'task_status.dart';

class AppTask {
  const AppTask({
    required this.id,
    required this.title,
    required this.status,
    this.progress,
    this.error,
  });

  final String id;
  final String title;
  final TaskStatus status;

  /// Fraction done (0–1) while running, or `null` when unknown.
  final double? progress;

  final Object? error;

  AppTask copyWith({TaskStatus? status, double? progress, Object? error}) {
    return AppTask(
      id: id,
      title: title,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}
