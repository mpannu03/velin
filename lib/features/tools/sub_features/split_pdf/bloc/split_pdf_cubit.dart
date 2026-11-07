import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'split_pdf_input.dart';
import 'split_pdf_state.dart';

class SplitPdfCubit extends Cubit<SplitPdfState>
    with ToolTaskRunner<SplitPdfState> {
  SplitPdfCubit({
    required this.filePicker,
    required this._splitPdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const SplitPdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final SplitPdfEngine _splitPdfEngine;

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
      ),
    );
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
    final directoryPath = await pickDirectory();

    if (directoryPath == null || isClosed) {
      return;
    }

    emit(state.copyWith(outputDirectory: directoryPath));
  }

  Future<void> split() async {
    if (state.isSubmitting) {
      return;
    }

    // Resolve the input from the current state *now*: the task may sit in
    // the queue while the user keeps editing.
    final splitInput = _validateAndBuildInput();

    if (splitInput == null) {
      return;
    }

    final outputDirectory = Directory(state.outputDirectory!.trim());

    emit(state.copyWith(isSubmitting: true));

    var fileCount = 0;

    await runToolTask(
      taskName: 'split-pdf',
      operation: () async {
        final files = await _splitPdfEngine.split(
          input: splitInput,
          outputDirectory: outputDirectory,
        );

        fileCount = files.length;
      },
      successMessage: () {
        final count = fileCount;
        return (l10n) => l10n.toolsSplitSuccess(count);
      },
      failureMessage: (l10n) => l10n.toolsSplitFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  SplitPdfInput? _validateAndBuildInput() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsSplitWarningNoFile);
      return null;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsSplitWarningNoFolder);
      return null;
    }

    switch (state.mode) {
      case SplitPdfMode.byPageCount:
        if (!state.hasValidPageCount) {
          notifyWarning((l10n) => l10n.toolsSplitWarningPagesPerFile);
          return null;
        }

      case SplitPdfMode.bySelection:
        if (!state.hasValidSelections) {
          notifyWarning((l10n) => l10n.toolsSplitWarningNoSelection);
          return null;
        }

      case SplitPdfMode.extractAllPages:
        break;
    }

    try {
      return SplitPdfToolInput(
        filePath: state.inputFilePath!,
        selections: state.selections,
        pageCount: state.parsedPageCount,
      ).toSplitInput(state.mode);
    } on PageSelectionError {
      notifyError((l10n) => l10n.toolsSplitSelectionInvalid);
      return null;
    }
  }
}
