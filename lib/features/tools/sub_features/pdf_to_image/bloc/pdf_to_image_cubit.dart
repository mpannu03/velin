import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'pdf_to_image_input.dart';
import 'pdf_to_image_state.dart';

class PdfToImageCubit extends Cubit<PdfToImageState> {
  PdfToImageCubit({
    required this._l10n,
    required this._filePicker,
    required this._pdfToImageEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const PdfToImageState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final PdfToImageEngine _pdfToImageEngine;
  final TaskManager _taskManager;
  final AppEffectController _appEffectController;

  Future<void> pickFile() async {
    final result = await _filePicker.pickFile(allowedExtensions: ['pdf']);

    switch (result) {
      case Success(data: final filePath):
        final directory = directoryWithTrailingSeparator(filePath);
        final fileName = fileNameFromPath(filePath);

        final outputDirectory = '$directory${fileName}_images/';

        emit(
          state.copyWith(
            inputFilePath: filePath,
            outputDirectory: outputDirectory,
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsPdfToImageFailed);
    }
  }

  void changeScope(PdfToImagePageScope scope) {
    if (scope == state.scope) {
      return;
    }

    emit(state.copyWith(scope: scope));
  }

  void updateSelection(String? selection) {
    emit(state.copyWith(selection: selection ?? ''));
  }

  void changeFormat(PdfImageFormat format) {
    if (format == state.format) {
      return;
    }

    emit(state.copyWith(format: format));
  }

  void changeColorMode(PdfImageColorMode colorMode) {
    if (colorMode == state.colorMode) {
      return;
    }

    emit(state.copyWith(colorMode: colorMode));
  }

  void changeDpi(int dpi) {
    if (dpi == state.dpi) {
      return;
    }

    emit(state.copyWith(dpi: dpi));
  }

  void changeQuality(int quality) {
    final clamped = quality.clamp(1, 100);

    if (clamped == state.quality) {
      return;
    }

    emit(state.copyWith(quality: clamped));
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

        _notifyError(_l10n.toolsPdfToImageFailed);
    }
  }

  Future<void> convert() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final input = PdfToImageToolInput(
      filePath: state.inputFilePath!,
      scope: state.scope,
      selection: state.selection,
      format: state.format,
      colorMode: state.colorMode,
      dpi: state.dpi,
      quality: state.quality,
    );

    final PdfToImageInput engineInput;

    try {
      engineInput = input.toPdfToImageInput();
    } on PageSelectionError {
      _notifyWarning(_l10n.toolsPdfToImageSelectionInvalid);
      return;
    }

    final outputDirectory = Directory(state.outputDirectory!.trim());

    emit(state.copyWith(isSubmitting: true));

    try {
      var fileCount = 0;

      await _taskManager.submit(
        id: 'pdf-to-image-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsPdfToImageButton,
        operation: () async {
          final files = await _pdfToImageEngine.convert(
            input: engineInput,
            outputDirectory: outputDirectory,
          );

          fileCount = files.length;
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsPdfToImageSuccess(fileCount),
        type: NotificationType.success,
      );
    } catch (_) {
      _notifyError(_l10n.toolsPdfToImageFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsPdfToImageWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsPdfToImageWarningNoFolder);
      return false;
    }

    if (state.scope.requiresSelection && !state.hasValidSelection) {
      _notifyWarning(_l10n.toolsPdfToImageWarningNoSelection);
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
