import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'rotate_pdf_input.dart';
import 'rotate_pdf_state.dart';

class RotatePdfCubit extends Cubit<RotatePdfState>
    with ToolTaskRunner<RotatePdfState> {
  RotatePdfCubit({
    required this.filePicker,
    required this._rotatePdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const RotatePdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final RotatePdfEngine _rotatePdfEngine;

  Future<void> pickFile() async {
    final filePath = await pickSingleFile(const ['pdf']);

    if (filePath == null || isClosed) {
      return;
    }

    emit(
      state.copyWith(
        inputFilePath: filePath,
        outputDirectory:
            state.outputDirectory ?? directoryWithTrailingSeparator(filePath),
        outputFileName: '${fileNameFromPath(filePath)}_rotated.pdf',
      ),
    );
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
    final directoryPath = await pickDirectory();

    if (directoryPath == null || isClosed) {
      return;
    }

    emit(state.copyWith(outputDirectory: directoryPath));
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

    final PageSelection? pageSelection;

    try {
      pageSelection = input.parsedSelection;
    } on PageSelectionError {
      notifyWarning((l10n) => l10n.toolsRotateSelectionInvalid);
      return;
    }

    final inputFile = File(state.inputFilePath!.trim());
    final outputFile = File(
      joinOutputPath(state.outputDirectory!, state.outputFileName!),
    );

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'rotate-pdf',
      operation: () => _rotatePdfEngine.rotate(
        inputFile: inputFile,
        outputFile: outputFile,
        degrees: input.direction.degrees,
        selection: pageSelection,
      ),
      successMessage: () =>
          (l10n) => l10n.toolsRotateSuccess,
      failureMessage: (l10n) => l10n.toolsRotateFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsRotateWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsRotateWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsRotateWarningNoFileName);
      return false;
    }

    if (state.scope.requiresSelection && !state.hasValidSelection) {
      notifyWarning((l10n) => l10n.toolsRotateWarningNoSelection);
      return false;
    }

    return true;
  }
}
