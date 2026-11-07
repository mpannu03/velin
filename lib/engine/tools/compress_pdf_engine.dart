import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_cos/pdf_cos.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

class CompressPdfInput {
  const CompressPdfInput({required this.file, this.compressionLevel = 75})
    : assert(compressionLevel >= 0 && compressionLevel <= 100);

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

    ensureOutputDiffersFromInputs(outputFile, [input.file]);

    final inputPath = input.file.path;
    final deflateLevel = (level * 9 / 100).round();

    // Parsing and re-compressing every stream is pure Dart CPU work that
    // scales with file size; on the UI isolate it would freeze the window.
    final outputBytes = await runInBackground(_compressFile, (
      inputPath,
      deflateLevel,
    ));

    return writeBytesAtomically(outputFile, outputBytes);
  }
}

/// Runs on a background isolate: top-level so it captures nothing.
Uint8List _compressFile((String, int) job) {
  final (inputPath, deflateLevel) = job;

  final sourceBytes = File(inputPath).readAsBytesSync();

  final document = CosDocument.open(sourceBytes);

  if (document.isEncrypted) {
    throw const PasswordRequiredFailure();
  }

  final result = CosCompactor(document, deflateLevel: deflateLevel).run();

  // Never make the file bigger.
  return result.bytes.length < sourceBytes.length ? result.bytes : sourceBytes;
}
