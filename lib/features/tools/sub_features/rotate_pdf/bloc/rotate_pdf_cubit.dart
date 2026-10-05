import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'rotate_pdf_input.dart';
import 'rotate_pdf_state.dart';

class RotatePdfCubit extends Cubit<RotatePdfState> {
  RotatePdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._rotatePdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const RotatePdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final RotatePdfEngine _rotatePdfEngine;
  final TaskManager _taskManager;
  final AppEffectController _appEffectController;

  Future<void> pickFile() async {
    final result = await _filePicker.pickFile(allowedExtensions: ['pdf']);

    switch (result) {
      case Success(data: final filePath):
        emit(
          state.copyWith(
            inputFilePath: filePath,
            outputDirectory:
                state.outputDirectory ??
                directoryWithTrailingSeparator(filePath),
            outputFileName: '${fileNameFromPath(filePath)}_rotated.pdf',
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsRotateFailed);
    }
  }

  void changeDirection(RotatePdfDirection direction) {
    if (direction == state.direction) {
      return;
    }

    emit(state.copyWith(direction: direction));
  }

  void changeScope(RotatePdfPageScope scope) {
    if (scope == state.scope) {
      return;
    }

    emit(state.copyWith(scope: scope));
  }

  void updateSelection(String? selection) {
    emit(state.copyWith(selection: selection ?? ''));
  }

  void updateOutputFileName(String? outputFileName) {
    emit(
      state.copyWith(
        outputFileName: normalizePdfFileName(outputFileName ?? ''),
      ),
    );
  }

  Future<void> pickOutputDirectory() async {
    final result = await _filePicker.pickDirectory();

    switch (result) {
      case Success(data: final directoryPath):
        emit(state.copyWith(outputDirectory: directoryPath));

      case Failure(error: final error):
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsRotateFailed);
    }
  }

  Future<void> rotate() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final input = RotatePdfToolInput(
      filePath: state.inputFilePath!,
      direction: state.direction,
      scope: state.scope,
      selection: state.selection,
    );

    PageSelection? pageSelection;

    try {
      pageSelection = input.parsedSelection;
    } on PageSelectionError {
      _notifyWarning(_l10n.toolsRotateSelectionInvalid);
      return;
    }

    final inputFile = File(state.inputFilePath!.trim());
    final outputFile = File(
      '${_normalizedDirectory(state.outputDirectory!.trim())}'
      '${Platform.pathSeparator}'
      '${state.outputFileName!.trim()}',
    );

    emit(state.copyWith(isSubmitting: true));

    try {
      await _taskManager.submit(
        id: 'rotate-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsRotateButton,
        operation: () async {
          await _rotatePdfEngine.rotate(
            inputFile: inputFile,
            outputFile: outputFile,
            degrees: input.direction.degrees,
            selection: pageSelection,
          );
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsRotateSuccess,
        type: NotificationType.success,
      );
    } catch (_) {
      _notifyError(_l10n.toolsRotateFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsRotateWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsRotateWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsRotateWarningNoFileName);
      return false;
    }

    if (state.scope.requiresSelection && !state.hasValidSelection) {
      _notifyWarning(_l10n.toolsRotateWarningNoSelection);
      return false;
    }

    return true;
  }

  /// Strips trailing separators so joining with [Platform.pathSeparator]
  /// never produces a doubled separator.
  String _normalizedDirectory(String directory) {
    return directory.replaceFirst(RegExp(r'[/\\]+$'), '');
  }

  void _notifyWarning(String message) {
    _appEffectController.notifyUser(
      message: message,
      type: NotificationType.warning,
    );
  }

  void _notifyError(String message) {
    _appEffectController.notifyUser(
      message: message,
      type: NotificationType.error,
    );
  }
}
