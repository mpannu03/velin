import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'encrypt_pdf_input.dart';
import 'encrypt_pdf_state.dart';

class EncryptPdfCubit extends Cubit<EncryptPdfState>
    with ToolTaskRunner<EncryptPdfState> {
  EncryptPdfCubit({
    required this.filePicker,
    required this._encryptPdfEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const EncryptPdfState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final EncryptPdfEngine _encryptPdfEngine;

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
        outputFileName: '${fileNameFromPath(filePath)}_protected.pdf',
      ),
    );
  }

  void updateUserPassword(String? password) {
    emit(state.copyWith(userPassword: password ?? ''));
  }

  void updateOwnerPassword(String? password) {
    emit(state.copyWith(ownerPassword: password ?? ''));
  }

  void changeLevel(EncryptPdfEncryptionLevel level) {
    if (level == state.level) {
      return;
    }

    emit(state.copyWith(level: level));
  }

  void changePermissions(EncryptPdfPermissionPreset permissions) {
    if (permissions == state.permissions) {
      return;
    }

    emit(state.copyWith(permissions: permissions));
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

  Future<void> protect() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final engineInput = state.toolInput.toEncryptPdfInput();

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'encrypt-pdf',
      operation: () => _encryptPdfEngine.encrypt(engineInput),
      successMessage: () =>
          (l10n) => l10n.toolsProtectSuccess,
      failureMessage: (l10n) => l10n.toolsProtectFailed,
      describeFailure: (failure) => switch (failure) {
        // The source is already protected: the engine opens it without a
        // password, so this is how that surfaces. The fix is to unlock it
        // first, which deserves its own message.
        PasswordRequiredFailure() => (
          l10n,
        ) => l10n.toolsProtectAlreadyEncrypted,
        _ => null,
      },
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsProtectWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsProtectWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsProtectWarningNoFileName);
      return false;
    }

    if (!state.hasProtection) {
      notifyWarning((l10n) => l10n.toolsProtectWarningNoProtection);
      return false;
    }

    if (state.hasDuplicatePasswords) {
      notifyWarning((l10n) => l10n.toolsProtectWarningPasswordsMatch);
      return false;
    }

    return true;
  }
}
