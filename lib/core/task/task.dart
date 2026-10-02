import 'task_status.dart';

export 'task_manager.dart';
export 'task_status.dart';

class AppTask {
  const AppTask({
    required this.id,
    required this.title,
    required this.status,
    this.error,
  });

  final String id;
  final String title;
  final TaskStatus status;
  final Object? error;

  AppTask copyWith({
    TaskStatus? status,
    Object? error,
  }) {
    return AppTask(
      id: id,
      title: title,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}