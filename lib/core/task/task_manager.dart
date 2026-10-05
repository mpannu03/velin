import 'dart:async';

import 'task.dart';

class TaskManager {
  TaskManager();

  final List<_TaskEntry> _queue = [];
  final Map<String, AppTask> _tasks = {};

  final StreamController<List<AppTask>> _controller =
      StreamController<List<AppTask>>.broadcast();

  bool _running = false;

  Stream<List<AppTask>> get tasks => _controller.stream;

  List<AppTask> get currentTasks => List.unmodifiable(_tasks.values);

  Future<void> submit({
    required String id,
    required String title,
    required Future<void> Function() operation,
  }) {
    final task = AppTask(id: id, title: title, status: TaskStatus.queued);

    _tasks[id] = task;

    final completer = Completer<void>();

    _queue.add(
      _TaskEntry(task: task, operation: operation, completer: completer),
    );

    _emit();

    unawaited(_processQueue());

    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_running) {
      return;
    }

    _running = true;

    try {
      while (_queue.isNotEmpty) {
        final entry = _queue.removeAt(0);

        _update(entry.task.copyWith(status: TaskStatus.running));

        try {
          await entry.operation();

          _update(entry.task.copyWith(status: TaskStatus.completed));

          entry.completer.complete();
        } catch (error) {
          _update(entry.task.copyWith(status: TaskStatus.failed, error: error));

          entry.completer.completeError(error);
        }
      }
    } finally {
      _running = false;
    }
  }

  void _update(AppTask task) {
    _tasks[task.id] = task;
    _emit();
  }

  void _emit() {
    _controller.add(currentTasks);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _TaskEntry {
  const _TaskEntry({
    required this.task,
    required this.operation,
    required this.completer,
  });

  final AppTask task;
  final Future<void> Function() operation;
  final Completer<void> completer;
}
