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

import 'extract_pdf_state.dart';

class ExtractPdfCubit extends Cubit<ExtractPdfState> {
  ExtractPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._extractPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const ExtractPdfState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final ExtractPdfEngine _extractPdfEngine;
  final TaskManager _taskManager;
  final AppEffectController _appEffectController;

  Future<void> pickFile() async {
    final result = await _filePicker.pickFile(
      allowedExtensions: ['pdf'],
    );

    switch (result) {
      case Success(data: final filePath):
        final outputFileName ='${fileNameFromPath(filePath)}_extracted.pdf';

        emit(
          state.copyWith(
            filePath: filePath,
            outputDirectory: state.outputDirectory ??
                directoryWithTrailingSeparator(filePath),
            outputFileName: outputFileName,
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _appEffectController.notifyUser(
          message: _l10n.toolsExtractFailed,
          type: NotificationType.error,
        );
    }
  }

  void updateSelection(String? pageSelection) {
    emit(state.copyWith(pageSelection: pageSelection));
  }

  Future<void> pickOutputDirectory() async {
    final result = await _filePicker.pickDirectory();

    switch (result) {
      case Success(data: final directoryPath):
        emit(
          state.copyWith(outputDirectory: directoryPath),
        );

      case Failure(error: final error):
        if (error is DocumentFilePickerError) {
          return;
        }

        _appEffectController.notifyUser(
          message: _l10n.toolsExtractFailed,
          type: NotificationType.error,
        );
    }
  }

  Future<void> extract() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    late final PageSelection pageSelection;

    try {
      pageSelection = PageSelectionParser().parse(state.pageSelection ?? '');
    } on PageSelectionError {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractSelectionInvalid,
        type: NotificationType.warning,
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final filePath = File(state.filePath!);
      final directory = _normalizedDirectory(state.outputDirectory!);
      final outputFile = File(
        '$directory'
        '${Platform.pathSeparator}'
        '${state.outputFileName!.trim()}',
      );

      await _taskManager.submit(
        id: 'extract-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsExtractButton,
        operation: () async {
          await _extractPdfEngine.extract(
            inputFile: filePath,
            selection: pageSelection,
            outputFile: outputFile,
          );
          _appEffectController.notifyUser(
            message: _l10n.toolsExtractSuccess,
            type: NotificationType.success,
          );
        },
      );
    } catch (_) {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractFailed,
        type: NotificationType.error,
      );
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasValidInputFilePath) {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractWarningNoFile,
        type: NotificationType.warning,
      );
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractWarningNoFolder,
        type: NotificationType.warning,
      );
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractWarningNoFileName,
        type: NotificationType.warning,
      );
      return false;
    }

    return true;
  }

  /// Strips trailing separators so joining with [Platform.pathSeparator]
  /// never produces a doubled separator.
  String _normalizedDirectory(String directory) {
    return directory.replaceFirst(RegExp(r'[/\\]+$'), '');
  }

  void updateOutputFileName(String? outputFileName) {
    final fileName = normalizePdfFileName(outputFileName ?? '');
    emit(state.copyWith(outputFileName: fileName));
  }
}