import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:velin/core/error/error.dart';

final _random = Random();

/// Writes [target] so that it is either fully written or left untouched.
///
/// [write] receives a temporary file next to [target] (same folder, so the
/// final rename stays on one volume and is atomic). When [write] completes,
/// the temporary file replaces [target]; if it throws, the temporary file is
/// deleted and any existing [target] is left exactly as it was.
///
/// Without this, a crash, a full disk or a locked file midway through saving
/// leaves a truncated PDF behind, possibly in place of a good one.
Future<File> writeAtomically(
  File target,
  Future<void> Function(File temporary) write,
) async {
  await target.parent.create(recursive: true);

  final temporary = File(
    p.join(
      target.parent.path,
      '.${p.basename(target.path)}.${_random.nextInt(1 << 32)}.tmp',
    ),
  );

  try {
    await write(temporary);
    return await temporary.rename(target.path);
  } catch (_) {
    try {
      if (await temporary.exists()) await temporary.delete();
    } on FileSystemException {
      // Best effort: the original error is what matters.
    }
    rethrow;
  }
}

/// [writeAtomically] for an in-memory result.
Future<File> writeBytesAtomically(File target, List<int> bytes) {
  return writeAtomically(
    target,
    (temporary) => temporary.writeAsBytes(bytes, flush: true),
  );
}

/// Throws [OutputSameAsInputFailure] when [output] is the same file as any of
/// [inputs].
///
/// Paths are canonicalized, so `C:\Docs\a.pdf` and `c:/docs/A.PDF` match on
/// Windows, and `..` segments are resolved.
void ensureOutputDiffersFromInputs(File output, Iterable<File> inputs) {
  final outputPath = p.canonicalize(output.path);

  for (final input in inputs) {
    if (p.canonicalize(input.path) == outputPath) {
      throw const OutputSameAsInputFailure();
    }
  }
}
