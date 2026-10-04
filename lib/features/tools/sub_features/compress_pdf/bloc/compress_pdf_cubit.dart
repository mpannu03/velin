import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'compress_pdf_input.dart';
import 'compress_pdf_state.dart';

class CompressPdfCubit extends Cubit<CompressPdfState> {
  CompressPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._compressPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const CompressPdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final CompressPdfEngine _compressPdfEngine;
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
            outputFileName: '${fileNameFromPath(filePath)}_compressed.pdf',
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsCompressFailed);
    }
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
    final result = await _filePicker.pickDirectory();

    switch (result) {
      case Success(data: final directoryPath):
        emit(state.copyWith(outputDirectory: directoryPath));

      case Failure(error: final error):
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsCompressFailed);
    }
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

    try {
      await _taskManager.submit(
        id: 'compress-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsCompressButton,
        operation: () async {
          await _compressPdfEngine.compress(
            input: engineInput,
            outputFile: outputFile,
          );
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsCompressSuccess,
        type: NotificationType.success,
      );
    } on UnsupportedError {
      // The engine throws this when the document carries an /Encrypt entry.
      // That is a wrong pick rather than a failure, so explain it.
      _notifyWarning(_l10n.toolsCompressEncrypted);
    } on ArgumentError {
      // The output path matched the input path, so nothing was written.
      _notifyWarning(_l10n.toolsCompressWarningNoFileName);
    } catch (_) {
      _notifyError(_l10n.toolsCompressFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsCompressWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsCompressWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsCompressWarningNoFileName);
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