import 'dart:async';

import 'package:logging/logging.dart';
import 'package:velin/core/error/error.dart';

import 'task.dart';

final _log = Logger('velin.task');

/// Runs long operations one at a time, tracks their status and progress, and
/// lets them be cancelled.
class TaskManager {
  TaskManager();

  final List<_TaskEntry> _queue = [];
  final Map<String, AppTask> _tasks = {};
  final Map<String, CancellationToken> _tokens = {};

  final StreamController<List<AppTask>> _controller =
      StreamController<List<AppTask>>.broadcast();

  bool _running = false;

  Stream<List<AppTask>> get tasks => _controller.stream;

  List<AppTask> get currentTasks => List.unmodifiable(_tasks.values);

  /// Queues [operation]. The returned future completes when it finishes, or
  /// fails with an [AppFailure] (a [CancelledFailure] when cancelled).
  Future<void> submit({
    required String id,
    required String title,
    required TaskOperation operation,
  }) {
    final task = AppTask(id: id, title: title, status: TaskStatus.queued);

    _tasks[id] = task;
    _tokens[id] = CancellationToken();

    final completer = Completer<void>();

    _queue.add(
      _TaskEntry(task: task, operation: operation, completer: completer),
    );

    _emit();

    unawaited(_processQueue());

    return completer.future;
  }

  /// Cancels task [id].
  ///
  /// A queued task is dropped without running. A running task is asked to
  /// stop and does so at its next cancellation check. Unknown or finished
  /// tasks are ignored.
  void cancel(String id) {
    final queuedIndex = _queue.indexWhere((entry) => entry.task.id == id);

    if (queuedIndex >= 0) {
      final entry = _queue.removeAt(queuedIndex);
      _tokens.remove(id);
      _update(entry.task.copyWith(status: TaskStatus.cancelled));
      entry.completer.completeError(const CancelledFailure());
      return;
    }

    _tokens[id]?.cancel();
  }

  Future<void> _processQueue() async {
    if (_running) {
      return;
    }

    _running = true;

    try {
      while (_queue.isNotEmpty) {
        final entry = _queue.removeAt(0);
        final id = entry.task.id;

        _update(entry.task.copyWith(status: TaskStatus.running));

        final context = TaskContext(
          token: _tokens[id],
          onProgress: (fraction) =>
              _update(_tasks[id]!.copyWith(progress: fraction)),
        );

        try {
          await entry.operation(context);

          _update(_tasks[id]!.copyWith(status: TaskStatus.completed));

          entry.completer.complete();
        } catch (error, stackTrace) {
          // Unexpected errors are logged as SEVERE by mapError itself.
          final failure = mapError(error, stackTrace);

          if (failure.isCancellation) {
            _log.info('Task "${entry.task.title}" ($id) cancelled');
            _update(_tasks[id]!.copyWith(status: TaskStatus.cancelled));
          } else {
            if (!failure.isUnexpected) {
              _log.info('Task "${entry.task.title}" ($id) failed: $failure');
            }

            _update(
              _tasks[id]!.copyWith(status: TaskStatus.failed, error: failure),
            );
          }

          entry.completer.completeError(failure, stackTrace);
        } finally {
          _tokens.remove(id);
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
    if (_controller.isClosed) return;
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
  final TaskOperation operation;
  final Completer<void> completer;
}
