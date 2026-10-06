import 'package:flutter/foundation.dart';

import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import 'image_to_pdf_input.dart';

class ImageToPdfState {
  const ImageToPdfState({
    this.inputs = const [],
    this.viewMode = ImagePickerViewMode.list,
    this.pageSize = ImageToPdfPageSize.auto,
    this.orientation = ImageToPdfOrientation.auto,
    this.fit = ImageToPdfFit.contain,
    this.outputFileName = 'images.pdf',
    this.outputDirectory,
    this.isSubmitting = false,
  });

  final List<ImageToPdfToolInput> inputs;

  /// Whether the picker shows the images as a list or as a grid.
  final ImagePickerViewMode viewMode;

  final ImageToPdfPageSize pageSize;
  final ImageToPdfOrientation orientation;
  final ImageToPdfFit fit;

  final String outputFileName;
  final String? outputDirectory;
  final bool isSubmitting;

  bool get hasImages => inputs.isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName => outputFileName.trim().isNotEmpty;

  bool get canConvert =>
      hasImages &&
      hasValidOutputFileName &&
      hasValidOutputDirectory &&
      !isSubmitting;

  ImageToPdfState copyWith({
    List<ImageToPdfToolInput>? inputs,
    ImagePickerViewMode? viewMode,
    ImageToPdfPageSize? pageSize,
    ImageToPdfOrientation? orientation,
    ImageToPdfFit? fit,
    String? outputFileName,
    Object? outputDirectory = _unset,
    bool? isSubmitting,
  }) {
    return ImageToPdfState(
      inputs: inputs ?? this.inputs,
      viewMode: viewMode ?? this.viewMode,
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      fit: fit ?? this.fit,
      outputFileName: outputFileName ?? this.outputFileName,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  bool operator ==(covariant ImageToPdfState other) {
    if (identical(this, other)) return true;

    return listEquals(other.inputs, inputs) &&
        other.viewMode == viewMode &&
        other.pageSize == pageSize &&
        other.orientation == orientation &&
        other.fit == fit &&
        other.outputFileName == outputFileName &&
        other.outputDirectory == outputDirectory &&
        other.isSubmitting == isSubmitting;
  }

  @override
  int get hashCode {
    return inputs.hashCode ^
        viewMode.hashCode ^
        pageSize.hashCode ^
        orientation.hashCode ^
        fit.hashCode ^
        outputFileName.hashCode ^
        outputDirectory.hashCode ^
        isSubmitting.hashCode;
  }
}

const _unset = Object();
