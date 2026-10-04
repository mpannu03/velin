import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_cos/pdf_cos.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'decrypt_pdf_input.dart';
import 'decrypt_pdf_state.dart';

class DecryptPdfCubit extends Cubit<DecryptPdfState> {
  DecryptPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._decryptPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const DecryptPdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final DecryptPdfEngine _decryptPdfEngine;
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
            outputFileName: '${fileNameFromPath(filePath)}_unlocked.pdf',
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsUnlockFailed);
    }
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
    final result = await _filePicker.pickDirectory();

    switch (result) {
      case Success(data: final directoryPath):
        emit(state.copyWith(outputDirectory: directoryPath));

      case Failure(error: final error):
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsUnlockFailed);
    }
  }

  Future<void> unlock() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final engineInput = state.toolInput.toDecryptPdfInput();

    emit(state.copyWith(isSubmitting: true));

    try {
      await _taskManager.submit(
        id: 'decrypt-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsUnlockButton,
        operation: () async {
          await _decryptPdfEngine.decrypt(engineInput);
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsUnlockSuccess,
        type: NotificationType.success,
      );
    } on CosPasswordException {
      // The password opened neither the user nor the owner door. Worth its own
      // message: the user can almost always fix this by retyping it.
      _notifyWarning(_l10n.toolsUnlockWrongPassword);
    } on StateError {
      // The engine throws this when the document has no /Encrypt entry, which
      // is a wrong pick rather than a failure.
      _notifyWarning(_l10n.toolsUnlockNotEncrypted);
    } catch (_) {
      _notifyError(_l10n.toolsUnlockFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsUnlockWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsUnlockWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsUnlockWarningNoFileName);
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
