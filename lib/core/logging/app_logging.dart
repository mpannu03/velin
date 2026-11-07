import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'log_file_writer.dart';

/// Routes every [Logger] record in the app to a rotating log file (and to the
/// debugger console in debug builds).
///
/// Logs stay on the user's machine. They are only shared if the user attaches
/// them to a bug report, so never log passwords or document contents.
class AppLogging {
  AppLogging._(this._writer, this._subscription);

  /// Configures [Logger.root] and starts writing records.
  ///
  /// [directory] defaults to `<application support>/logs`. If the log file
  /// cannot be opened the app keeps running with console-only logging.
  static Future<AppLogging> initialize({
    Directory? directory,
    Level? level,
    bool logToConsole = !kReleaseMode,
  }) async {
    Logger.root.level = level ?? (kReleaseMode ? Level.INFO : Level.ALL);

    LogFileWriter? writer;

    try {
      final logDirectory = directory ?? await _defaultLogDirectory();
      writer = LogFileWriter(directory: logDirectory)..open();
    } catch (error) {
      // Logging must never prevent the app from starting.
      debugPrint('Velin: file logging disabled ($error)');
      writer = null;
    }

    final subscription = Logger.root.onRecord.listen((record) {
      writer?.write(formatLogRecord(record));

      if (logToConsole) {
        developer.log(
          record.message,
          name: record.loggerName,
          level: record.level.value,
          time: record.time,
          error: record.error,
          stackTrace: record.stackTrace,
        );
      }
    });

    return AppLogging._(writer, subscription);
  }

  static Future<Directory> _defaultLogDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'logs'));
  }

  final LogFileWriter? _writer;
  final StreamSubscription<LogRecord> _subscription;

  /// Folder containing the log files, or `null` when file logging is off.
  /// Intended for a "Open logs folder" action in the Help menu.
  Directory? get logDirectory => _writer?.directory;

  /// The log file currently being written, or `null` when file logging is off.
  File? get currentLogFile => _writer?.currentFile;

  Future<void> dispose() async {
    await _subscription.cancel();
    _writer?.close();
  }
}

/// Formats a record as a single entry; error and stack trace go on the
/// following indented lines so entries stay easy to scan.
@visibleForTesting
String formatLogRecord(LogRecord record) {
  final buffer = StringBuffer()
    ..write(record.time.toIso8601String())
    ..write(' ')
    ..write(record.level.name.padRight(7))
    ..write(' [')
    ..write(record.loggerName)
    ..write('] ')
    ..write(record.message);

  if (record.error != null) {
    buffer
      ..write('\n  error: ')
      ..write(record.error);
  }

  final stackTrace = record.stackTrace;
  if (stackTrace != null && stackTrace != StackTrace.empty) {
    final lines = stackTrace.toString().trimRight().split('\n');
    for (final line in lines) {
      buffer
        ..write('\n    ')
        ..write(line);
    }
  }

  return buffer.toString();
}
