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
      case Success(data: final filePaths):
        final dirName = directoryWithTrailingSeparator(filePaths);
        emit(
          state.copyWith(
            filePath: filePaths,
            outputDirectory: state.outputDirectory ?? dirName,
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

    emit(state.copyWith(isSubmitting: true));

    try {
      final filePath = File(state.filePath!);
      final pageSelection = PageSelectionParser().parse(state.pageSelection ?? '');
      final outputFile = File(
        '${state.outputDirectory}'
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
            outputFile: outputFile
          );
          _appEffectController.notifyUser(
            message: _l10n.toolsExtractSuccess,
            type: NotificationType.success,
          );
        }
      );
    } catch (_) {
      _appEffectController.notifyUser(
        message: _l10n.toolsExtractFailed, 
        type: NotificationType.error
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

  void updateFilePath(String? filePath) {
    emit(state.copyWith(filePath: filePath));
  }

  void updatePageSelection(String? pageSelection) {
    emit(state.copyWith(pageSelection: pageSelection));
  }

  void updateOutputDirectory(String? outputDirectory) {
    emit(state.copyWith(outputDirectory: outputDirectory));
  }

  void updateOutputFileName(String? outputFileName) {
    emit(state.copyWith(outputFileName: outputFileName));
  }
}