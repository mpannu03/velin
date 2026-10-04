import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

import 'add_watermark_input.dart';
import 'add_watermark_state.dart';

class AddWatermarkCubit extends Cubit<AddWatermarkState> {
  AddWatermarkCubit({
    required this._l10n,
    required this._filePicker,
    required this._addWatermarkEngine,
    required this._taskManager,
    required this._appEffectController,
  }) : super(const AddWatermarkState());

  final AppLocalizations _l10n;
  final DocumentFilePicker _filePicker;
  final AddWatermarkEngine _addWatermarkEngine;
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
            outputFileName: '${fileNameFromPath(filePath)}_watermarked.pdf',
          ),
        );

      case Failure(error: final error):
        // The user cancelled the picker: not an error, stay quiet.
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsWatermarkFailed);
    }
  }

  Future<void> pickWatermarkImage() async {
    final result = await _filePicker.pickFile(
      allowedExtensions: AddWatermarkToolInput.supportedImageExtensions,
    );

    switch (result) {
      case Success(data: final filePath):
        emit(state.copyWith(imageFilePath: filePath));

      case Failure(error: final error):
        if (error is DocumentFilePickerError) {
          return;
        }

        _notifyError(_l10n.toolsWatermarkFailed);
    }
  }

  void clearWatermarkImage() {
    emit(state.copyWith(imageFilePath: null));
  }

  void changeType(WatermarkType type) {
    if (type == state.type) {
      return;
    }

    emit(state.copyWith(type: type));
  }

  void updateText(String text) {
    if (text == state.text) {
      return;
    }

    emit(state.copyWith(text: text));
  }

  void changeFontName(String? fontName) {
    if (fontName == state.fontName) {
      return;
    }

    emit(state.copyWith(fontName: fontName));
  }

  void changeFontSize(double fontSize) {
    final clamped = fontSize.clamp(
      AddWatermarkToolInput.minFontSize.toDouble(),
      AddWatermarkToolInput.maxFontSize.toDouble(),
    );

    if (clamped == state.fontSize) {
      return;
    }

    emit(state.copyWith(fontSize: clamped));
  }

  /// Accepts `#RRGGBB` and bare `RRGGBB`; anything else is rejected with a
  /// warning so the tool stays disabled rather than failing on submit.
  void changeColorHex(String value) {
    final normalized = value.trim();

    if (normalized == state.colorHex) {
      return;
    }

    if (!AddWatermarkToolInput.colorHexPattern.hasMatch(normalized)) {
      _notifyWarning(_l10n.toolsWatermarkWarningInvalidColor);
      return;
    }

    emit(state.copyWith(colorHex: '#${normalizeHexColor(normalized)}'));
  }

  void changeOpacity(double opacity) {
    final clamped = opacity.clamp(
      AddWatermarkToolInput.minOpacity,
      AddWatermarkToolInput.maxOpacity,
    );

    if (clamped == state.opacity) {
      return;
    }

    emit(state.copyWith(opacity: clamped));
  }

  void changeRotation(double rotation) {
    final clamped = rotation.clamp(
      AddWatermarkToolInput.minRotation,
      AddWatermarkToolInput.maxRotation,
    );

    if (clamped == state.rotation) {
      return;
    }

    emit(state.copyWith(rotation: clamped));
  }

  void changePosition(WatermarkPosition position) {
    if (position == state.position) {
      return;
    }

    emit(state.copyWith(position: position));
  }

  void changeXOffset(double offset) {
    final clamped = offset.clamp(
      AddWatermarkToolInput.minOffset,
      AddWatermarkToolInput.maxOffset,
    );

    if (clamped == state.xOffset) {
      return;
    }

    emit(state.copyWith(xOffset: clamped));
  }

  void changeYOffset(double offset) {
    final clamped = offset.clamp(
      AddWatermarkToolInput.minOffset,
      AddWatermarkToolInput.maxOffset,
    );

    if (clamped == state.yOffset) {
      return;
    }

    emit(state.copyWith(yOffset: clamped));
  }

  void changeImageWidthPercent(double percent) {
    final clamped = percent.clamp(
      AddWatermarkToolInput.minImageWidthPercent,
      AddWatermarkToolInput.maxImageWidthPercent,
    );

    if (clamped == state.imageWidthPercent) {
      return;
    }

    emit(state.copyWith(imageWidthPercent: clamped));
  }

  void changeLayer(WatermarkLayer layer) {
    if (layer == state.layer) {
      return;
    }

    emit(state.copyWith(layer: layer));
  }

  void changeScope(WatermarkPageScope scope) {
    if (scope == state.scope) {
      return;
    }

    emit(state.copyWith(scope: scope));
  }

  void updateSelection(String selection) {
    emit(state.copyWith(selection: selection));
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

        _notifyError(_l10n.toolsWatermarkFailed);
    }
  }

  Future<void> applyWatermark() async {
    if (state.isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final AddWatermarkInput engineInput;

    try {
      engineInput = state.toolInput.toAddWatermarkInput();
    } on PageSelectionError {
      _notifyWarning(_l10n.toolsWatermarkSelectionInvalid);
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      await _taskManager.submit(
        id: 'add-watermark-${DateTime.now().microsecondsSinceEpoch}',
        title: _l10n.toolsWatermarkButton,
        operation: () async {
          await _addWatermarkEngine.addWatermark(input: engineInput);
        },
      );

      _appEffectController.notifyUser(
        message: _l10n.toolsWatermarkSuccess,
        type: NotificationType.success,
      );
    } on ArgumentError {
      // The engine rejects unusable inputs such as an unreadable image or a
      // color it cannot parse, so explain rather than report a crash.
      _notifyWarning(_l10n.toolsWatermarkFailed);
    } catch (_) {
      _notifyError(_l10n.toolsWatermarkFailed);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  bool _validateInputs() {
    if (!state.hasInputFile) {
      _notifyWarning(_l10n.toolsWatermarkWarningNoFile);
      return false;
    }

    if (!state.hasWatermarkContent) {
      _notifyWarning(
        state.type == WatermarkType.text
            ? _l10n.toolsWatermarkWarningNoText
            : _l10n.toolsWatermarkWarningNoImage,
      );
      return false;
    }

    if (!state.hasValidColor) {
      _notifyWarning(_l10n.toolsWatermarkWarningInvalidColor);
      return false;
    }

    if (!state.hasValidScopeConfig) {
      _notifyWarning(_l10n.toolsWatermarkWarningNoSelection);
      return false;
    }

    if (!state.hasValidOutputDirectory) {
      _notifyWarning(_l10n.toolsWatermarkWarningNoFolder);
      return false;
    }

    if (!state.hasValidOutputFileName) {
      _notifyWarning(_l10n.toolsWatermarkWarningNoFileName);
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
