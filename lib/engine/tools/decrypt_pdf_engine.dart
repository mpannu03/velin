import 'dart:io';

import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:velin/core/error/error.dart';

import 'decrypt_pdf_input.dart';

class DecryptPdfEngine {
  const DecryptPdfEngine({required this._pdf});

  final Pdf _pdf;

  Future<File> decrypt(DecryptPdfInput input) async {
    if (!await input.inputFile.exists()) {
      throw FileSystemException('Input file not found.', input.inputFile.path);
    }

    await input.outputFile.parent.create(recursive: true);

    final source = FileSource(input.inputFile);
    final output = await FileSink.create(input.outputFile);

    try {
      await _pdf.decrypt(source, output, password: input.password);

      return input.outputFile;
    } on StateError catch (error, stackTrace) {
      // Raised when the document has no /Encrypt entry: a wrong pick, not a
      // crash.
      throw DocumentNotEncryptedFailure(cause: error, stackTrace: stackTrace);
    } finally {
      await output.close();
    }
  }
}
