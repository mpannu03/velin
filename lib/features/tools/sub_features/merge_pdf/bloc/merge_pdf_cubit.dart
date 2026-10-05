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

import 'merge_pdf_input.dart';
import 'merge_pdf_state.dart';

class MergePdfCubit extends Cubit<MergePdfState> {
  MergePdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._mergePdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const MergePdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final MergePdfEngine _mergePdfEngine;
  final TaskManager _taskManager;
  final AppEffectController _appEffectController;

  Future<void> pickFiles() async {
    final result = await _filePicker.pickFiles(allowedExtensions: ['pdf']);

    switch (result) {
      case Success(data: final filePaths):
        final dirName = directoryWithTrailingSeparator(filePaths.first);
        emit(
          state.copyWith(
            inputs: [
              ...state.inputs,
              for (final filePath in filePaths)
                MergePdfToolInput(filePath: filePath),
            ],
            outputDirectory: state.outputDirectory ?? dirName,
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _appEffectController.notifyUser(
          message: _l10n.toolsMergeFailed,
          type: NotificationType.error,
        );
    }
  }

  void removeFile(int index) {
    final inputs = [...state.inputs]..removeAt(index);

    emit(state.copyWith(inputs: inputs));
  }

  void reorderFiles(int oldIndex, int newIndex) {
    final inputs = [...state.inputs];

    final input = inputs.removeAt(oldIndex);
    inputs.insert(newIndex, input);

    emit(state.copyWith(inputs: inputs));
  }

  void updatePageSelection(int index, String value) {
    final inputs = [...state.inputs];

    inputs[index] = inputs[index].copyWith(pageSelection: value);

    emit(state.copyWith(inputs: inputs));
  }

  void updateOutputFileName(String value) {
    final fileName = normalizePdfFileName(value);
    emit(state.copyWith(outputFileName: fileName));
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

        _appEffectController.notifyUser(
          message: _l10n.toolsMergeFailed,
          type: NotificationType.error,
        );
    }
  }

  Future<void> merge() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final outputFile = File(
      '${state.outputDirectory}'
      '${Platform.pathSeparator}'
      '${state.outputFileName.trim()}',
    );

    emit(state.copyWith(isSubmitting: true));

    try {
      await _taskManager.submit(
        id: 'merge-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsMergeButton,
        operation: () async {
          await _mergePdfEngine.merge(
            inputs: [for (final input in state.inputs) input.toPdfInput()],
            outputFile: outputFile,
          );
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsMergeSuccess,
        type: NotificationType.success,
      );
    } catch (_) {
      _appEffectController.notifyUser(
        message: _l10n.toolsMergeFailed,
        type: NotificationType.error,
      );
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFiles) {
      _notifyWarning(_l10n.toolsMergeWarningNoFiles);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsMergeWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsMergeWarningNoFileName);
      return false;
    }

    for (final input in state.inputs) {
      try {
        input.toPdfInput();
      } on PageSelectionError {
        _appEffectController.notifyUser(
          message: _l10n.toolsMergePageSelectionInvalid(
            _fileName(input.filePath),
          ),
          type: NotificationType.error,
        );
        return false;
      }
    }

    return true;
  }

  void _notifyWarning(String message) {
    _appEffectController.notifyUser(
      message: message,
      type: NotificationType.warning,
    );
  }

  String _fileName(String path) => path.split(Platform.pathSeparator).last;
}
