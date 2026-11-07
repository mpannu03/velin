import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/utils/utils.dart';

import 'image_to_pdf_input.dart';
import 'image_to_pdf_state.dart';

class ImageToPdfCubit extends Cubit<ImageToPdfState>
    with ToolTaskRunner<ImageToPdfState> {
  ImageToPdfCubit({
    required this.filePicker,
    required this._imageToPdfEngine,
    required this.taskManager,
    required this.appEffectController,
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

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final ImageToPdfEngine _imageToPdfEngine;

  Future<void> pickImages() async {
    final filePaths = await pickMultipleFiles(supportedExtensions);

    if (filePaths.isEmpty || isClosed) {
      return;
    }

    emit(
      state.copyWith(
        inputs: [
          ...state.inputs,
          for (final filePath in filePaths)
            ImageToPdfToolInput(filePath: filePath),
        ],
        outputDirectory:
            state.outputDirectory ??
            directoryWithTrailingSeparator(filePaths.first),
      ),
    );
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
    final directoryPath = await pickDirectory();

    if (directoryPath == null || isClosed) {
      return;
    }

    emit(state.copyWith(outputDirectory: directoryPath));
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
    final imageCount = state.inputs.length;

    final outputFile = File(
      joinOutputPath(state.outputDirectory!, state.outputFileName),
    );

    emit(state.copyWith(isSubmitting: true));

    await runToolTask(
      taskName: 'image-to-pdf',
      operation: () =>
          _imageToPdfEngine.convert(input: input, outputFile: outputFile),
      successMessage: () =>
          (l10n) => l10n.toolsImageToPdfSuccess(imageCount),
      failureMessage: (l10n) => l10n.toolsImageToPdfFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasImages) {
      notifyWarning((l10n) => l10n.toolsImageToPdfWarningNoImages);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsImageToPdfWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      notifyWarning((l10n) => l10n.toolsImageToPdfWarningNoFileName);
      return false;
    }

    return true;
  }
}
