import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:velin/core/logging/logging.dart';

void main() {
  group('formatLogRecord', () {
    test('formats a plain record on one line', () {
      final record = LogRecord(
        Level.INFO,
        'Opened document',
        'velin.reader',
        null,
        null,
        null,
        null,
      );

      final line = formatLogRecord(record);

      expect(line, endsWith(' INFO    [velin.reader] Opened document'));
      expect(line.split('\n'), hasLength(1));
    });

    test('appends error and indented stack trace', () {
      final record = LogRecord(
        Level.SEVERE,
        'Merge failed',
        'velin.task',
        const FileSystemException('Access denied', 'C:/out.pdf'),
        StackTrace.fromString('#0 main (file.dart:1)\n#1 run (file.dart:2)'),
        null,
        null,
      );

      final lines = formatLogRecord(record).split('\n');

      expect(lines[0], contains('SEVERE  [velin.task] Merge failed'));
      expect(lines[1], startsWith('  error: FileSystemException'));
      expect(lines[2], '    #0 main (file.dart:1)');
      expect(lines[3], '    #1 run (file.dart:2)');
    });
  });

  group('AppLogging', () {
    late Directory tempDir;
    late AppLogging logging;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('velin_app_logging_');
      logging = await AppLogging.initialize(
        directory: tempDir,
        level: Level.INFO,
        logToConsole: false,
      );
    });

    tearDown(() async {
      await logging.dispose();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('writes records at or above the configured level to file', () async {
      Logger('velin.test').fine('too detailed');
      Logger('velin.test').warning('worth keeping');

      // Logger delivers records synchronously, but let the listener run.
      await Future<void>.delayed(Duration.zero);

      final contents = logging.currentLogFile!.readAsStringSync();

      expect(contents, contains('[velin.test] worth keeping'));
      expect(contents, isNot(contains('too detailed')));
      expect(logging.logDirectory!.path, tempDir.path);
    });
  });
}
