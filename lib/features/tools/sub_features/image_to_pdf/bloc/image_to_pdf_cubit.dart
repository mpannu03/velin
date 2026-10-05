import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'image_to_pdf_input.dart';
import 'image_to_pdf_state.dart';

class ImageToPdfCubit extends Cubit<ImageToPdfState> {
  ImageToPdfCubit({
    required this._l10n,
    required this._filePicker,
    required this._imageToPdfEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const ImageToPdfState());

  /// Image formats `ImageToPdfEngine` can decode.
  static const supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'tif',
    'tiff',
  ];

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final ImageToPdfEngine _imageToPdfEngine;
  final TaskManager _taskManager;
  final AppEffectController _appEffectController;

  Future<void> pickImages() async {
    final result = await _filePicker.pickFiles(
      allowedExtensions: supportedExtensions,
    );

    switch (result) {
      case Success(data: final filePaths):
        if (filePaths.isEmpty) {
          return;
        }

        final directory = directoryWithTrailingSeparator(filePaths.first);

        emit(
          state.copyWith(
            inputs: [
              ...state.inputs,
              for (final filePath in filePaths)
                ImageToPdfToolInput(filePath: filePath),
            ],
            outputDirectory: state.outputDirectory ?? directory,
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsImageToPdfFailed);
    }
  }

  void removeImage(int index) {
    final inputs = [...state.inputs]..removeAt(index);

    emit(state.copyWith(inputs: inputs));
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) {
      return;
    }

    final inputs = [...state.inputs];

    final input = inputs.removeAt(oldIndex);

    // A drag past the last slot produces an index one past the end.
    final target = newIndex.clamp(0, inputs.length);
    inputs.insert(target, input);

    emit(state.copyWith(inputs: inputs));
  }

  void changeViewMode(ImagePickerViewMode viewMode) {
    if (viewMode == state.viewMode) {
      return;
    }

    emit(state.copyWith(viewMode: viewMode));
  }

  void changePageSize(ImageToPdfPageSize pageSize) {
    if (pageSize == state.pageSize) {
      return;
    }

    emit(state.copyWith(pageSize: pageSize));
  }

  void changeOrientation(ImageToPdfOrientation orientation) {
    if (orientation == state.orientation) {
      return;
    }

    emit(state.copyWith(orientation: orientation));
  }

  void changeFit(ImageToPdfFit fit) {
    if (fit == state.fit) {
      return;
    }

    emit(state.copyWith(fit: fit));
  }

  void updateOutputFileName(String value) {
    emit(state.copyWith(outputFileName: normalizePdfFileName(value)));
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

        _notifyError(_l10n.toolsImageToPdfFailed);
    }
  }

  Future<void> convert() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final input = state.inputs.toImageToPdfInput(
      pageSize: state.pageSize,
      orientation: state.orientation,
      fit: state.fit,
    );

    final outputFile = File(
      '${state.outputDirectory}'
      '${Platform.pathSeparator}'
      '${state.outputFileName.trim()}',
    );

    emit(state.copyWith(isSubmitting: true));

    try {
      await _taskManager.submit(
        id: 'image-to-pdf-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsImageToPdfButton,
        operation: () async {
          await _imageToPdfEngine.convert(input: input, outputFile: outputFile);
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsImageToPdfSuccess(state.inputs.length),
        type: NotificationType.success,
      );
    } catch (_) {
      _notifyError(_l10n.toolsImageToPdfFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasImages) {
      _notifyWarning(_l10n.toolsImageToPdfWarningNoImages);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsImageToPdfWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsImageToPdfWarningNoFileName);
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
