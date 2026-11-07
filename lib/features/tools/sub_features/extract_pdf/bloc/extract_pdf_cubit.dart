import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'extract_pdf_state.dart';

class ExtractPdfCubit extends Cubit<ExtractPdfState>
    with ToolTaskRunner<ExtractPdfState> {
  ExtractPdfCubit({
    required this.filePicker,
    required this._extractPdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const ExtractPdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final ExtractPdfEngine _extractPdfEngine;

  Future<void> pickFile() async {
    final filePath = await pickSingleFile(const ['pdf']);

    if (filePath == null || isClosed) {
      return;
    }

    emit(
      state.copyWith(
        filePath: filePath,
        outputDirectory:
            state.outputDirectory ?? directoryWithTrailingSeparator(filePath),
        outputFileName: '${fileNameFromPath(filePath)}_extracted.pdf',
      ),
    );
  }

  void updateSelection(String? pageSelection) {
    emit(state.copyWith(pageSelection: pageSelection));
  }

  Future<void> pickOutputDirectory() async {
    final directoryPath = await pickDirectory();

    if (directoryPath == null || isClosed) {
      return;
    }

    emit(state.copyWith(outputDirectory: directoryPath));
  }

  Future<void> extract() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final PageSelection pageSelection;

    try {
      pageSelection = PageSelectionParser().parse(state.pageSelection ?? '');
    } on PageSelectionError {
      notifyWarning((l10n) => l10n.toolsExtractSelectionInvalid);
      return;
    }

    final inputFile = File(state.filePath!);
    final outputFile = File(
      joinOutputPath(state.outputDirectory!, state.outputFileName!),
    );

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'extract-pdf',
      operation: () => _extractPdfEngine.extract(
        inputFile: inputFile,
        selection: pageSelection,
        outputFile: outputFile,
      ),
      successMessage: () =>
          (l10n) => l10n.toolsExtractSuccess,
      failureMessage: (l10n) => l10n.toolsExtractFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasValidInputFilePath) {
      notifyWarning((l10n) => l10n.toolsExtractWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsExtractWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsExtractWarningNoFileName);
      return false;
    }

    return true;
  }

  void updateOutputFileName(String? outputFileName) {
    final fileName = normalizePdfFileName(outputFileName ?? '');
    emit(state.copyWith(outputFileName: fileName));
  }
}
