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

import 'split_pdf_input.dart';
import 'split_pdf_state.dart';

class SplitPdfCubit extends Cubit<SplitPdfState> {
  SplitPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._splitPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const SplitPdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final SplitPdfEngine _splitPdfEngine;
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
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsSplitFailed);
    }
  }

  void changeMode(SplitPdfMode mode) {
    if (mode == state.mode) {
      return;
    }

    emit(state.copyWith(mode: mode));
  }

  void updatePageCount(String value) {
    emit(state.copyWith(pageCount: value));
  }

  void addSelection() {
    emit(state.copyWith(selections: [...state.selections, '']));
  }

  void updateSelection(int index, String value) {
    final selections = [...state.selections];

    if (index < 0 || index >= selections.length) {
      return;
    }

    selections[index] = value;

    emit(state.copyWith(selections: selections));
  }

  void removeSelection(int index) {
    final selections = [...state.selections];

    if (index < 0 || index >= selections.length) {
      return;
    }

    selections.removeAt(index);

    emit(state.copyWith(selections: selections));
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

        _notifyError(_l10n.toolsSplitFailed);
    }
  }

  Future<void> split() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final input = SplitPdfToolInput(
      filePath: state.inputFilePath!,
      selections: state.selections,
      pageCount: state.parsedPageCount,
    );

    final outputDirectory = Directory(state.outputDirectory!.trim());

    emit(state.copyWith(isSubmitting: true));

    try {
      var fileCount = 0;

      await _taskManager.submit(
        id: 'split-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsSplitButton,
        operation: () async {
          final files = await _splitPdfEngine.split(
            input: input.toSplitInput(state.mode),
            outputDirectory: outputDirectory,
          );

          fileCount = files.length;
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsSplitSuccess(fileCount),
        type: NotificationType.success,
      );
    } catch (_) {
      _notifyError(_l10n.toolsSplitFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsSplitWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsSplitWarningNoFolder);
      return false;
    }

    switch (state.mode) {
      case SplitPdfMode.byPageCount:
        if (!state.hasValidPageCount) {
          _notifyWarning(_l10n.toolsSplitWarningPagesPerFile);
          return false;
        }

      case SplitPdfMode.bySelection:
        if (!state.hasValidSelections) {
          _notifyWarning(_l10n.toolsSplitWarningNoSelection);
          return false;
        }

        try {
          SplitPdfToolInput(
            filePath: state.inputFilePath!,
            selections: state.selections,
          ).toSplitInput(state.mode);
        } on PageSelectionError catch (_) {
          _notifyError(_l10n.toolsSplitSelectionInvalid);
          return false;
        }

      case SplitPdfMode.extractAllPages:
        break;
    }

    return true;
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
