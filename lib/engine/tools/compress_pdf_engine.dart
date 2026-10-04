import 'dart:io';
import 'package:pdf_cos/pdf_cos.dart';

class CompressPdfInput {
  const CompressPdfInput({
    required this.file,
    this.compressionLevel = 75,
  }) : assert(compressionLevel >= 0 && compressionLevel <= 100);

  final File file;
  final int compressionLevel;
}

class CompressPdfEngine {
  const CompressPdfEngine();

  Future<File> compress({
    required CompressPdfInput input,
    required File outputFile,
  }) async {
    final level = input.compressionLevel;

    if (level < 0 || level > 100) {
      throw ArgumentError.value(
        level,
        'compressionLevel',
        'Must be between 0 and 100.',
      );
    }

    if (input.file.absolute.path == outputFile.absolute.path) {
      throw ArgumentError(
        'The output file must differ from the input file.',
      );
    }

    final sourceBytes = await input.file.readAsBytes();

    final document = CosDocument.open(sourceBytes);

    if (document.isEncrypted) {
      throw UnsupportedError(
        'Encrypted PDFs cannot currently be compressed.',
      );
    }

    final deflateLevel = (level * 9 / 100).round();

    final result = CosCompactor(
      document,
      deflateLevel: deflateLevel,
    ).run();

    final outputBytes = result.bytes.length < sourceBytes.length
        ? result.bytes
        : sourceBytes;

    await outputFile.writeAsBytes(
      outputBytes,
      flush: true,
    );

    return outputFile;
  }
}
