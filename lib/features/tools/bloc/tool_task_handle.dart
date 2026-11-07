import 'package:flutter/foundation.dart';

enum ToolTaskPhase { idle, queued, running, cancelling }

@immutable
class ToolTaskStatus {
  const ToolTaskStatus._(this.phase, this.progress);

  static const idle = ToolTaskStatus._(ToolTaskPhase.idle, null);
  static const queued = ToolTaskStatus._(ToolTaskPhase.queued, null);

  const ToolTaskStatus.running([double? progress])
    : this._(ToolTaskPhase.running, progress);

  final ToolTaskPhase phase;

  /// Fraction done (0–1), or `null` while unknown.
  final double? progress;

  bool get isActive => phase != ToolTaskPhase.idle;

  bool get canCancel =>
      phase == ToolTaskPhase.queued || phase == ToolTaskPhase.running;

  ToolTaskStatus cancelling() =>
      ToolTaskStatus._(ToolTaskPhase.cancelling, progress);

  @override
  bool operator ==(Object other) =>
      other is ToolTaskStatus &&
      other.phase == phase &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(phase, progress);

  @override
  String toString() => 'ToolTaskStatus($phase, $progress)';
}

/// The live status of a tool's current task, and a way to cancel it.
///
/// Lives next to the tool's cubit state rather than inside it: progress can
/// tick many times per second, and keeping it out of the state means the
/// form does not rebuild (and state tests do not change) on every tick.
class ToolTaskHandle {
  final ValueNotifier<ToolTaskStatus> _status = ValueNotifier(
    ToolTaskStatus.idle,
  );

  VoidCallback? _cancel;
  bool _disposed = false;

  ValueListenable<ToolTaskStatus> get status => _status;

  /// Asks the current task to stop. Does nothing when idle.
  void cancel() {
    if (_disposed) return;
    final current = _status.value;
    if (!current.canCancel) return;

    _status.value = current.cancelling();
    _cancel?.call();
  }

  /// Called by `ToolTaskRunner`.
  void queued({required VoidCallback cancel}) {
    if (_disposed) return;
    _cancel = cancel;
    _status.value = ToolTaskStatus.queued;
  }

  /// Called by `ToolTaskRunner`.
  void running([double? progress]) {
    if (_disposed) return;
    // A cancel request wins over late progress updates.
    if (_status.value.phase == ToolTaskPhase.cancelling) return;
    _status.value = ToolTaskStatus.running(progress);
  }

  /// Called by `ToolTaskRunner`.
  void finished() {
    if (_disposed) return;
    _cancel = null;
    _status.value = ToolTaskStatus.idle;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _status.dispose();
  }
}
