import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'decrypt_pdf_input.dart';
import 'decrypt_pdf_state.dart';

class DecryptPdfCubit extends Cubit<DecryptPdfState>
    with ToolTaskRunner<DecryptPdfState> {
  DecryptPdfCubit({
    required this.filePicker,
    required this._decryptPdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const DecryptPdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final DecryptPdfEngine _decryptPdfEngine;

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
        outputFileName: '${fileNameFromPath(filePath)}_unlocked.pdf',
      ),
    );
  }

  void updatePassword(String? password) {
    emit(state.copyWith(password: password ?? ''));
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

  Future<void> unlock() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final engineInput = state.toolInput.toDecryptPdfInput();

    if (!await confirmOverwrite(engineInput.outputFile) || isClosed) {
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'decrypt-pdf',
      operation: () => _decryptPdfEngine.decrypt(engineInput),
      successMessage: () =>
          (l10n) => l10n.toolsUnlockSuccess,
      failureMessage: (l10n) => l10n.toolsUnlockFailed,
      describeFailure: (failure) => switch (failure) {
        // The password opened neither the user nor the owner door. The user
        // can almost always fix this by retyping it.
        PasswordRequiredFailure() ||
        WrongPasswordFailure() => (l10n) => l10n.toolsUnlockWrongPassword,
        DocumentNotEncryptedFailure() => (l10n) => l10n.toolsUnlockNotEncrypted,
        _ => null,
      },
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsUnlockWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsUnlockWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsUnlockWarningNoFileName);
      return false;
    }

    return true;
  }
}
