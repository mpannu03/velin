import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/shared/extensions/app_failure_ext.dart';

/// Shared plumbing for the PDF tool cubits: file pickers, running the
/// operation as a background task, and telling the user how it went.
///
/// Every method here handles its own errors and never throws, so cubits only
/// describe *what* to do and *what to say*, not how to recover.
mixin ToolTaskRunner<S> on Cubit<S> {
  DocumentFilePicker get filePicker;
  TaskManager get taskManager;
  AppEffectController get appEffectController;

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

  /// Runs [operation] through the [TaskManager] and reports the outcome.
  ///
  /// * On success, shows [successMessage] (resolved after the operation, so
  ///   it may use values the operation produced).
  /// * On failure, [describeFailure] may return a tool-specific message for
  ///   a known failure; otherwise the failure's own message is shown, or
  ///   [failureMessage] if the failure is unexpected.
  ///
  /// Returns whether the operation succeeded. Never throws.
  Future<bool> runToolTask({
    required String taskName,
    required Future<void> Function() operation,
    required LocalizedMessage Function() successMessage,
    required LocalizedMessage failureMessage,
    LocalizedMessage? Function(AppFailure failure)? describeFailure,
  }) async {
    try {
      await taskManager.submit(
        id: '$taskName-${DateTime.now().microsecondsSinceEpoch}',
        title: taskName,
        operation: operation,
      );
    } catch (error, stackTrace) {
      final failure = mapError(error, stackTrace);
      final custom = describeFailure?.call(failure);

      if (custom != null) {
        notifyWarning(custom);
      } else {
        _reportFailure(failure, fallback: failureMessage);
      }

      return false;
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
