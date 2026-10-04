import 'dart:io';

import 'package:velin/engine/engine.dart';

/// User-facing model for the Unlock PDF tool.
class DecryptPdfToolInput {
  const DecryptPdfToolInput({
    required this.filePath,
    required this.outputFilePath,
    this.password = '',
  });

  final String filePath;
  final String outputFilePath;

  /// The current user or owner password. Empty when the document is
  /// unencrypted, or protected by permissions only.
  final String password;

  DecryptPdfToolInput copyWith({String? password}) {
    return DecryptPdfToolInput(
      filePath: filePath,
      outputFilePath: outputFilePath,
      password: password ?? this.password,
    );
  }
}

extension DecryptPdfMapper on DecryptPdfToolInput {
  DecryptPdfInput toDecryptPdfInput() {
    return DecryptPdfInput(
      inputFile: File(filePath),
      outputFile: File(outputFilePath),
      password: password,
    );
  }
}
