import 'dart:io';

class EncryptPdfInput {
  const EncryptPdfInput({
    required this.inputFile,
    required this.outputFile,
    required this.ownerPassword,
    this.userPassword = '',
    this.permissions = const PdfPermissions.all(),
    this.level = PdfEncryptionLevel.aes256,
  });

  final File inputFile;
  final File outputFile;

  final String ownerPassword;
  final String userPassword;

  final PdfPermissions permissions;
  final PdfEncryptionLevel level;
}

enum PdfEncryptionLevel {
  aes256,
  aes128,
  rc4,
}

class PdfPermissions {
  const PdfPermissions({
    this.print = true,
    this.printHq = true,
    this.modify = true,
    this.copy = true,
    this.annotate = true,
    this.fillForms = true,
    this.accessibility = true,
    this.assemble = true,
  });

  const PdfPermissions.all()
      : print = true,
        printHq = true,
        modify = true,
        copy = true,
        annotate = true,
        fillForms = true,
        accessibility = true,
        assemble = true;

  const PdfPermissions.readOnly()
      : print = true,
        printHq = true,
        modify = false,
        copy = false,
        annotate = false,
        fillForms = false,
        accessibility = true,
        assemble = false;
  
  const PdfPermissions.none()
      : print = false,
        printHq = false,
        modify = false,
        copy = false,
        annotate = false,
        fillForms = false,
        accessibility = false,
        assemble = false;

  final bool print;
  final bool printHq;
  final bool modify;
  final bool copy;
  final bool annotate;
  final bool fillForms;
  final bool accessibility;
  final bool assemble;
}