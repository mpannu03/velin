import 'dart:io';

import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart' as manipulator;

import 'encrypt_pdf_input.dart';

class EncryptPdfEngine {
  const EncryptPdfEngine({
    required this._pdf
  });

  final manipulator.Pdf _pdf;

  Future<File> encrypt(EncryptPdfInput input) async {
    if (!await input.inputFile.exists()) {
      throw FileSystemException(
        'Input file not found.',
        input.inputFile.path,
      );
    }

    await input.outputFile.parent.create(recursive: true);

    final source = FileSource(input.inputFile);
    final output = await FileSink.create(input.outputFile);

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

    return input.outputFile;
  }

  manipulator.PdfEncryptionAlgorithm _toAlgorithm(
    PdfEncryptionLevel level,
  ) {
    return switch (level) {
      PdfEncryptionLevel.aes256 =>
        manipulator.PdfEncryptionAlgorithm.aes256,
      PdfEncryptionLevel.aes128 =>
        manipulator.PdfEncryptionAlgorithm.aes128,
      PdfEncryptionLevel.rc4 =>
        manipulator.PdfEncryptionAlgorithm.rc4_128,
    };
  }
}