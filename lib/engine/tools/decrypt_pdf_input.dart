import 'dart:io';

class DecryptPdfInput {
  const DecryptPdfInput({
    required this.inputFile,
    required this.outputFile,
    this.password = '',
  });

  final File inputFile;
  final File outputFile;

  final String password;
}
