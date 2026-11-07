import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/utils/utils.dart';

import 'pdf_to_image_input.dart';
import 'pdf_to_image_state.dart';

class PdfToImageCubit extends Cubit<PdfToImageState>
    with ToolTaskRunner<PdfToImageState> {
  PdfToImageCubit({
    required this.filePicker,
    required this._pdfToImageEngine,
    required this.taskManager,
    required this.appEffectController,
  }) : super(const PdfToImageState());

  @override
  final DocumentFilePicker filePicker;
  @override
  final TaskManager taskManager;
  @override
  final AppEffectController appEffectController;

  final PdfToImageEngine _pdfToImageEngine;

  Future<void> pickFile() async {
    final filePath = await pickSingleFile(const ['pdf']);

    if (filePath == null || isClosed) {
      return;
    }

    final directory = directoryWithTrailingSeparator(filePath);
    final fileName = fileNameFromPath(filePath);

    emit(
      state.copyWith(
        inputFilePath: filePath,
        outputDirectory: '$directory${fileName}_images/',
      ),
    );
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
      notifyWarning((l10n) => l10n.toolsPdfToImageSelectionInvalid);
      return;
    }

    final outputDirectory = Directory(state.outputDirectory!.trim());

    emit(state.copyWith(isSubmitting: true));

    var fileCount = 0;

    await runToolTask(
      taskName: 'pdf-to-image',
      operation: (context) async {
        final files = await _pdfToImageEngine.convert(
          input: engineInput,
          outputDirectory: outputDirectory,
          context: context,
          confirmOverwrite: confirmOverwriteMany,
        );

        fileCount = files.length;
      },
      successMessage: () {
        final count = fileCount;
        return (l10n) => l10n.toolsPdfToImageSuccess(count);
      },
      failureMessage: (l10n) => l10n.toolsPdfToImageFailed,
    );

    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      notifyWarning((l10n) => l10n.toolsPdfToImageWarningNoFile);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      notifyWarning((l10n) => l10n.toolsPdfToImageWarningNoFolder);
      return false;
    }

    if (state.scope.requiresSelection && !state.hasValidSelection) {
      notifyWarning((l10n) => l10n.toolsPdfToImageWarningNoSelection);
      return false;
    }

    return true;
  }
}
