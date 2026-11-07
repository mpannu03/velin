import 'dart:io';

import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart' as manipulator;
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/core/task/task_context.dart';

import 'encrypt_pdf_input.dart';

class EncryptPdfEngine {
  const EncryptPdfEngine({required this._pdf});

  final manipulator.Pdf _pdf;

  Future<File> encrypt(EncryptPdfInput input, {TaskContext? context}) async {
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
        await _pdf.encrypt(
          source,
          output,
          encryption: manipulator.PdfEncryptionConfig(
            ownerPassword: input.ownerPassword,
            userPassword: input.userPassword,
            algorithm: _toAlgorithm(input.level),
            permissions: manipulator.PdfPermissions(
              print: input.permissions.print,
              printHq: input.permissions.printHq,
              modify: input.permissions.modify,
              copy: input.permissions.copy,
              annotate: input.permissions.annotate,
              fillForms: input.permissions.fillForms,
              accessibility: input.permissions.accessibility,
              assemble: input.permissions.assemble,
            ),
          ),
        );

        // Throwing here discards the temporary file, so nothing is saved.
        context?.throwIfCancelled();
      } finally {
        await output.close();
      }
    });
  }

  manipulator.PdfEncryptionAlgorithm _toAlgorithm(PdfEncryptionLevel level) {
    return switch (level) {
      PdfEncryptionLevel.aes256 => manipulator.PdfEncryptionAlgorithm.aes256,
      PdfEncryptionLevel.aes128 => manipulator.PdfEncryptionAlgorithm.aes128,
      PdfEncryptionLevel.rc4 => manipulator.PdfEncryptionAlgorithm.rc4_128,
    };
  }
}
