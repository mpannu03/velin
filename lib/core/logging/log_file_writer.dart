import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Appends log lines to `<directory>/<baseName>.log` and rotates the file once
/// it grows beyond [maxBytes].
///
/// At most [maxFiles] files are kept: `velin.log` (current), `velin.1.log`,
/// `velin.2.log`, ... where a higher number means older.
///
/// Writes are synchronous and unbuffered on purpose: the most valuable log
/// lines are the ones written right before a crash, and they must reach the
/// OS before the process dies. Log volume is low (INFO and above in release),
/// so the cost is negligible.
///
/// Any I/O failure disables the writer instead of throwing: logging must never
/// be the reason the app breaks.
class LogFileWriter {
  LogFileWriter({
    required this.directory,
    this.baseName = 'velin',
    this.maxBytes = 1024 * 1024,
    this.maxFiles = 3,
  }) : assert(maxBytes > 0),
       assert(maxFiles >= 1);

  final Directory directory;
  final String baseName;
  final int maxBytes;
  final int maxFiles;

  RandomAccessFile? _file;
  int _size = 0;

  /// The file currently being written to.
  File get currentFile => File(p.join(directory.path, '$baseName.log'));

  bool get isOpen => _file != null;

  File _rotatedFile(int index) =>
      File(p.join(directory.path, '$baseName.$index.log'));

  /// Opens (or creates) the current log file in append mode.
  ///
  /// Throws if the directory or file cannot be created, so the caller can
  /// decide to fall back to console-only logging.
  void open() {
    if (_file != null) return;

    directory.createSync(recursive: true);
    final file = currentFile.openSync(mode: FileMode.append);
    _file = file;
    _size = file.lengthSync();
  }

  void write(String line) {
    if (_file == null) return;

    final bytes = utf8.encode('$line\n');

    try {
      if (_size > 0 && _size + bytes.length > maxBytes) {
        _rotate();
      }

      _file!.writeFromSync(bytes);
      _size += bytes.length;
    } on FileSystemException {
      _disable();
    }
  }

  void _rotate() {
    _file!.closeSync();
    _file = null;

    if (maxFiles == 1) {
      currentFile.deleteSync();
    } else {
      final oldest = _rotatedFile(maxFiles - 1);
      if (oldest.existsSync()) oldest.deleteSync();

      for (var index = maxFiles - 2; index >= 1; index--) {
        final file = _rotatedFile(index);
        if (file.existsSync()) file.renameSync(_rotatedFile(index + 1).path);
      }

      currentFile.renameSync(_rotatedFile(1).path);
    }

    _file = currentFile.openSync(mode: FileMode.append);
    _size = 0;
  }

  void _disable() {
    try {
      _file?.closeSync();
    } on FileSystemException {
      // Nothing left to do; the writer is being disabled anyway.
    }
    _file = null;
  }

  void close() => _disable();
}
