import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'merge_pdf_input.dart';
import 'merge_pdf_state.dart';

class MergePdfCubit extends Cubit<MergePdfState>
    with ToolTaskRunner<MergePdfState> {
  MergePdfCubit({
    required this.filePicker,
    required this._mergePdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const MergePdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final MergePdfEngine _mergePdfEngine;

  Future<void> pickFiles() async {
    final filePaths = await pickMultipleFiles(const ['pdf']);

    if (filePaths.isEmpty || isClosed) {
      return;
    }

    emit(
      state.copyWith(
        inputs: [
          ...state.inputs,
          for (final filePath in filePaths)
            MergePdfToolInput(filePath: filePath),
        ],
        outputDirectory:
            state.outputDirectory ??
            directoryWithTrailingSeparator(filePaths.first),
      ),
    );
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
    final directoryPath = await pickDirectory();

    if (directoryPath == null || isClosed) {
      return;
    }

    emit(state.copyWith(outputDirectory: directoryPath));
  }

  Future<void> merge() async {
    if (state.isSubmitting) {
      return;
    }

    // Resolve everything from the current state *now*: the task may sit in
    // the queue while the user keeps editing the list.
    final engineInputs = _validateAndBuildInputs();

    if (engineInputs == null) {
      return;
    }

    final outputFile = File(
      joinOutputPath(state.outputDirectory!, state.outputFileName),
    );

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'merge-pdf',
      operation: () =>
          _mergePdfEngine.merge(inputs: engineInputs, outputFile: outputFile),
      successMessage: () =>
          (l10n) => l10n.toolsMergeSuccess,
      failureMessage: (l10n) => l10n.toolsMergeFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  List<MergePdfInput>? _validateAndBuildInputs() {
    if (!state.hasInputFiles) {
      notifyWarning((l10n) => l10n.toolsMergeWarningNoFiles);
      return null;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsMergeWarningNoFolder);
      return null;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsMergeWarningNoFileName);
      return null;
    }

    final engineInputs = <MergePdfInput>[];

    for (final input in state.inputs) {
      try {
        engineInputs.add(input.toPdfInput());
      } on PageSelectionError {
        final fileName = p.basename(input.filePath);
        notifyError((l10n) => l10n.toolsMergePageSelectionInvalid(fileName));
        return null;
      }
    }

    return engineInputs;
  }
}
