import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/shared/extensions/app_failure_ext.dart';

import 'tool_task_handle.dart';

export 'tool_task_handle.dart';

/// Shared plumbing for the PDF tool cubits: file pickers, running the
/// operation as a background task, and telling the user how it went.
///
/// Every method here handles its own errors and never throws, so cubits only
/// describe *what* to do and *what to say*, not how to recover.
mixin ToolTaskRunner<S> on Cubit<S> {
  DocumentFilePicker get filePicker;
  TaskManager get taskManager;
  AppEffectController get appEffectController;

  /// Status, progress and cancellation of the tool's current task, for the
  /// action bar.
  final ToolTaskHandle task = ToolTaskHandle();

  @override
  Future<void> close() {
    // If the page closes mid-task, stop the work rather than finishing a
    // result nobody is waiting for.
    task
      ..cancel()
      ..dispose();
    return super.close();
  }

  /// Picks one file. Returns `null` when cancelled or when the picker failed
  /// (the failure has already been reported).
  Future<String?> pickSingleFile(List<String> allowedExtensions) async {
    final result = await filePicker.pickFile(
      allowedExtensions: allowedExtensions,
    );

    return switch (result) {
      Success(:final data) => data,
      Failure(:final failure) => _reportPickerFailure(failure),
    };
  }

  /// Picks several files. Returns an empty list when cancelled or failed.
  Future<List<String>> pickMultipleFiles(List<String> allowedExtensions) async {
    final result = await filePicker.pickFiles(
      allowedExtensions: allowedExtensions,
    );

    return switch (result) {
      Success(:final data) => data,
      Failure(:final failure) => _reportPickerFailure(failure) ?? const [],
    };
  }

  /// Picks a folder. Returns `null` when cancelled or failed.
  Future<String?> pickDirectory() async {
    final result = await filePicker.pickDirectory();

    return switch (result) {
      Success(:final data) => data,
      Failure(:final failure) => _reportPickerFailure(failure),
    };
  }

  Null _reportPickerFailure(AppFailure failure) {
    _reportFailure(failure);
    return null;
  }

  /// Reports through [AppEffectController.notifyUser] (rather than
  /// `notifyFailure`) so tests can assert on the exact message shown.
  void _reportFailure(AppFailure failure, {LocalizedMessage? fallback}) {
    if (failure.isCancellation) return;

    notifyError((l10n) => failure.userMessage(l10n, fallback: fallback));
  }

  /// Asks before replacing [output] when it already exists.
  ///
  /// Returns `true` when it is fine to write (the file does not exist, or
  /// the user agreed to replace it).
  Future<bool> confirmOverwrite(File output) async {
    if (!await output.exists()) return true;

    final fileName = p.basename(output.path);

    return appEffectController.confirm(
      title: (l10n) => l10n.toolsOverwriteTitle,
      message: (l10n) => l10n.toolsOverwriteMessage(fileName),
      confirmLabel: (l10n) => l10n.toolsOverwriteConfirm,
      isDestructive: true,
    );
  }

  /// For tools that write several files: asks once before replacing the
  /// [existing] ones. Pass as the engine's `confirmOverwrite` callback.
  Future<bool> confirmOverwriteMany(List<File> existing) {
    if (existing.length == 1) return confirmOverwrite(existing.single);

    final count = existing.length;

    return appEffectController.confirm(
      title: (l10n) => l10n.toolsOverwriteTitle,
      message: (l10n) => l10n.toolsOverwriteManyMessage(count),
      confirmLabel: (l10n) => l10n.toolsOverwriteConfirm,
      isDestructive: true,
    );
  }

  /// Runs [operation] through the [TaskManager] and reports the outcome.
  ///
  /// * On success, shows [successMessage] (resolved after the operation, so
  ///   it may use values the operation produced).
  /// * On failure, [describeFailure] may return a tool-specific message for
  ///   a known failure; otherwise the failure's own message is shown, or
  ///   [failureMessage] if the failure is unexpected.
  ///
  /// * When the user cancels (through [task]), shows a short notice.
  ///
  /// [operation] receives a [TaskContext]; pass it to the engine so it can
  /// report progress and stop when cancelled. Progress and cancellation are
  /// exposed to the UI through [task].
  ///
  /// Returns whether the operation succeeded. Never throws.
  Future<bool> runToolTask({
    required String taskName,
    required TaskOperation operation,
    required LocalizedMessage Function() successMessage,
    required LocalizedMessage failureMessage,
    LocalizedMessage? Function(AppFailure failure)? describeFailure,
  }) async {
    final id = '$taskName-${DateTime.now().microsecondsSinceEpoch}';

    task.queued(cancel: () => taskManager.cancel(id));

    try {
      await taskManager.submit(
        id: id,
        title: taskName,
        operation: (context) {
          task.running();
          return operation(context.observedBy(task.running));
        },
      );
    } catch (error, stackTrace) {
      final failure = mapError(error, stackTrace);

      if (failure.isCancellation) {
        appEffectController.notifyUser(
          message: (l10n) => l10n.toolsTaskCancelled,
          type: NotificationType.info,
        );
        return false;
      }

      final custom = describeFailure?.call(failure);

      if (custom != null) {
        notifyWarning(custom);
      } else {
        _reportFailure(failure, fallback: failureMessage);
      }

      return false;
    } finally {
      if (!isClosed) task.finished();
    }

    appEffectController.notifyUser(
      message: successMessage(),
      type: NotificationType.success,
    );

    return true;
  }

  void notifyWarning(LocalizedMessage message) {
    appEffectController.notifyUser(
      message: message,
      type: NotificationType.warning,
    );
  }

  void notifyError(LocalizedMessage message) {
    appEffectController.notifyUser(
      message: message,
      type: NotificationType.error,
    );
  }
}
