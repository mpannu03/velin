import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_cos/pdf_cos.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'encrypt_pdf_input.dart';
import 'encrypt_pdf_state.dart';

class EncryptPdfCubit extends Cubit<EncryptPdfState> {
  EncryptPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._encryptPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const EncryptPdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final EncryptPdfEngine _encryptPdfEngine;
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
            outputFileName: '${fileNameFromPath(filePath)}_protected.pdf',
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsProtectFailed);
    }
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

  void toggleEncryptMetadata(bool encryptMetadata) {
    if (encryptMetadata == state.encryptMetadata) {
      return;
    }

    emit(state.copyWith(encryptMetadata: encryptMetadata));
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

        _notifyError(_l10n.toolsProtectFailed);
    }
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

    try {
      await _taskManager.submit(
        id: 'encrypt-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsProtectButton,
        operation: () async {
          await _encryptPdfEngine.encrypt(engineInput);
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsProtectSuccess,
        type: NotificationType.success,
      );
    } on UnsupportedEncryptionException {
      // The source is already protected: say so instead of a generic failure,
      // because the fix is to unlock it first.
      _notifyWarning(_l10n.toolsProtectAlreadyEncrypted);
    } catch (_) {
      _notifyError(_l10n.toolsProtectFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsProtectWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsProtectWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsProtectWarningNoFileName);
      return false;
    }

    if (!state.hasProtection) {
      _notifyWarning(_l10n.toolsProtectWarningNoProtection);
      return false;
    }

    if (state.hasDuplicatePasswords) {
      _notifyWarning(_l10n.toolsProtectWarningPasswordsMatch);
      return false;
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
