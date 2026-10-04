import 'dart:io';

import 'compress_pdf_input.dart';

class CompressPdfState {
  const CompressPdfState({
    this.inputFilePath,
    this.outputDirectory,
    this.outputFileName,
    this.quality = 75,
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final String? outputDirectory;
  final String? outputFileName;

  /// Compression effort from 0 to 100. Higher values keep more quality.
  final int quality;

  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  bool get canCompress =>
      hasInputFile &&
      hasValidOutputDirectory &&
      hasValidOutputFileName &&
      !isSubmitting;

  /// The tool input for the current state.
  ///
  /// [outputDirectory] and [outputFileName] are joined here so the cubit and
  /// the view agree on the final path.
  CompressPdfToolInput get toolInput {
    final directory = outputDirectory!.trim().replaceFirst(
      RegExp(r'[/\\]+$'),
      '',
    );

    return CompressPdfToolInput(
      filePath: inputFilePath!.trim(),
      outputFilePath:
          '$directory${Platform.pathSeparator}'
          '${outputFileName!.trim()}',
      quality: quality,
    );
  }

  CompressPdfState copyWith({
    Object? inputFilePath = _unset,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
    int? quality,
    bool? isSubmitting,
  }) {
    return CompressPdfState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
      quality: quality ?? this.quality,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();