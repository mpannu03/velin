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

/// Runs [body], which writes several files and records each one in
/// [written]. If [body] is cancelled, the files written so far are deleted
/// before the cancellation is rethrown, so a cancelled multi-file operation
/// leaves nothing behind.
Future<T> discardOnCancel<T>(
  List<File> written,
  Future<T> Function() body,
) async {
  try {
    return await body();
  } on CancelledFailure {
    for (final file in written) {
      try {
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // Best effort.
      }
    }
    rethrow;
  }
}

/// Asks whether the [existing] files may be replaced. Resolves to `false` to
/// abort.
typedef OverwriteConfirmation = Future<bool> Function(List<File> existing);

/// For operations that write several files whose names are only known once
/// the work starts: checks which of [planned] already exist and, if any do,
/// asks [confirm]. Throws [CancelledFailure] when the user declines, before
/// anything has been written.
Future<void> confirmOverwrites(
  List<File> planned,
  OverwriteConfirmation? confirm,
) async {
  if (confirm == null) return;

  final existing = [
    for (final file in planned)
      if (await file.exists()) file,
  ];

  if (existing.isNotEmpty && !await confirm(existing)) {
    throw const CancelledFailure();
  }
}
