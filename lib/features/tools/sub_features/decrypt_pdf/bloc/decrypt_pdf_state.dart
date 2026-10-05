// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'decrypt_pdf_input.dart';

class DecryptPdfState {
  const DecryptPdfState({
    this.inputFilePath,
    this.outputDirectory,
    this.outputFileName,
    this.password = '',
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final String? outputDirectory;
  final String? outputFileName;

  /// The password to authenticate with. Empty is allowed: a document may be
  /// restricted by permissions while still opening without a password.
  final String password;

  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  bool get hasPassword => password.trim().isNotEmpty;

  /// Unlike the protect tool there is no "nothing to do" case here: removing an
  /// /Encrypt entry is always worth writing, so the button needs only a file
  /// and a destination.
  bool get canDecrypt =>
      hasInputFile &&
      hasValidOutputDirectory &&
      hasValidOutputFileName &&
      !isSubmitting;

  /// The tool input for the current state.
  ///
  /// [outputDirectory] and [outputFileName] are joined here so the cubit and
  /// the view agree on the final path.
  DecryptPdfToolInput get toolInput {
    final directory = outputDirectory!.trim().replaceFirst(
      RegExp(r'[/\\]+$'),
      '',
    );

    return DecryptPdfToolInput(
      filePath: inputFilePath!.trim(),
      outputFilePath:
          '$directory${Platform.pathSeparator}'
          '${outputFileName!.trim()}',
      password: password,
    );
  }

  DecryptPdfState copyWith({
    Object? inputFilePath = _unset,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
    String? password,
    bool? isSubmitting,
  }) {
    return DecryptPdfState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  bool operator ==(covariant DecryptPdfState other) {
    if (identical(this, other)) return true;

    return other.inputFilePath == inputFilePath &&
        other.outputDirectory == outputDirectory &&
        other.outputFileName == outputFileName &&
        other.password == password &&
        other.isSubmitting == isSubmitting;
  }

  @override
  int get hashCode {
    return inputFilePath.hashCode ^
        outputDirectory.hashCode ^
        outputFileName.hashCode ^
        password.hashCode ^
        isSubmitting.hashCode;
  }
}

const _unset = Object();
