import 'dart:io';

import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/task/task_context.dart';

import 'decrypt_pdf_input.dart';

class DecryptPdfEngine {
  const DecryptPdfEngine({required this._pdf});

  final Pdf _pdf;

  Future<File> decrypt(DecryptPdfInput input, {TaskContext? context}) async {
    context?.throwIfCancelled();

    if (!await input.inputFile.exists()) {
      throw FileSystemException('Input file not found.', input.inputFile.path);
    }

    // FileSink.create truncates its target immediately, so writing over the
    // input would destroy it before it is read.
    ensureOutputDiffersFromInputs(input.outputFile, [input.inputFile]);

    return writeAtomically(input.outputFile, (temporary) async {
      final source = FileSource(input.inputFile);
      final output = await FileSink.create(temporary);

      try {
        await _pdf.decrypt(source, output, password: input.password);

        // Throwing here discards the temporary file, so nothing is saved.
        context?.throwIfCancelled();
      } on StateError catch (error, stackTrace) {
        // Raised when the document has no /Encrypt entry: a wrong pick, not
        // a crash.
        throw DocumentNotEncryptedFailure(cause: error, stackTrace: stackTrace);
      } finally {
        await output.close();
      }
    });
  }
}
