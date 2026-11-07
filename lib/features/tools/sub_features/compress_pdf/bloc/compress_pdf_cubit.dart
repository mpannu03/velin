import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'compress_pdf_input.dart';
import 'compress_pdf_state.dart';

class CompressPdfCubit extends Cubit<CompressPdfState>
    with ToolTaskRunner<CompressPdfState> {
  CompressPdfCubit({
    required this.filePicker,
    required this._compressPdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const CompressPdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final CompressPdfEngine _compressPdfEngine;

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
        outputFileName: '${fileNameFromPath(filePath)}_compressed.pdf',
      ),
    );
  }

  void changeQuality(int quality) {
    final clamped = quality.clamp(
      CompressPdfToolInput.minQuality,
      CompressPdfToolInput.maxQuality,
    );

    if (clamped == state.quality) {
      return;
    }

    emit(state.copyWith(quality: clamped));
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

  Future<void> compress() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final toolInput = state.toolInput;
    final engineInput = toolInput.toCompressPdfInput();
    final outputFile = File(toolInput.outputFilePath);

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'compress-pdf',
      operation: () => _compressPdfEngine.compress(
        input: engineInput,
        outputFile: outputFile,
      ),
      successMessage: () =>
          (l10n) => l10n.toolsCompressSuccess,
      failureMessage: (l10n) => l10n.toolsCompressFailed,
      describeFailure: (failure) => switch (failure) {
        // Compression works on unencrypted documents only: a wrong pick
        // rather than a failure, so explain it.
        PasswordRequiredFailure() => (l10n) => l10n.toolsCompressEncrypted,
        _ => null,
      },
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsCompressWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsCompressWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsCompressWarningNoFileName);
      return false;
    }

    return true;
  }
}
