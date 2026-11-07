import 'package:velin/core/error/error.dart';

/// Cooperative cancellation: long operations check [isCancelled] (or call
/// [throwIfCancelled]) between units of work such as pages or images.
///
/// Work that is already running inside a single call (one pdfium encode, one
/// background isolate) is not interrupted; the operation stops at the next
/// check.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  /// Throws [CancelledFailure] once [cancel] has been called.
  void throwIfCancelled() {
    if (_cancelled) throw const CancelledFailure();
  }
}

/// Reports progress as a fraction from 0 to 1.
typedef ProgressCallback = void Function(double fraction);

/// What a running task can see of its own lifecycle.
class TaskContext {
  TaskContext({CancellationToken? token, this._onProgress})
    : token = token ?? CancellationToken();

  /// A context nobody observes or cancels: for running an operation
  /// outside the task manager (tests, one-off calls).
  factory TaskContext.detached() => TaskContext();

  final CancellationToken token;
  final ProgressCallback? _onProgress;

  bool get isCancelled => token.isCancelled;

  void throwIfCancelled() => token.throwIfCancelled();

  /// Reports that [completed] of [total] units are done. Ignored when
  /// [total] is not positive.
  void reportProgress(int completed, int total) {
    if (total <= 0) return;
    _onProgress?.call((completed / total).clamp(0.0, 1.0));
  }

  /// A context sharing this token that also notifies [listener] about
  /// progress.
  TaskContext observedBy(ProgressCallback listener) {
    return TaskContext(
      token: token,
      onProgress: (fraction) {
        _onProgress?.call(fraction);
        listener(fraction);
      },
    );
  }
}

/// The work a task performs.
typedef TaskOperation = Future<void> Function(TaskContext context);
