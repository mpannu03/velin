import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/logging/logging.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('velin_log_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File logFile(String name) => File(p.join(tempDir.path, name));

  test('creates the directory and appends lines', () {
    final directory = Directory(p.join(tempDir.path, 'nested', 'logs'));
    final writer = LogFileWriter(directory: directory)..open();

    writer
      ..write('first')
      ..write('second')
      ..close();

    expect(File(p.join(directory.path, 'velin.log')).readAsLinesSync(), [
      'first',
      'second',
    ]);
  });

  test('appends to an existing log across sessions', () {
    LogFileWriter(directory: tempDir)
      ..open()
      ..write('session 1')
      ..close();

    LogFileWriter(directory: tempDir)
      ..open()
      ..write('session 2')
      ..close();

    expect(logFile('velin.log').readAsLinesSync(), ['session 1', 'session 2']);
  });

  test('rotates when the size limit is exceeded and keeps maxFiles', () {
    final writer = LogFileWriter(directory: tempDir, maxBytes: 10, maxFiles: 3)
      ..open();

    // Each line is 9 bytes including the newline, so every write rotates.
    for (final line in ['line-aaa', 'line-bbb', 'line-ccc', 'line-ddd']) {
      writer.write(line);
    }
    writer.close();

    expect(logFile('velin.log').readAsLinesSync(), ['line-ddd']);
    expect(logFile('velin.1.log').readAsLinesSync(), ['line-ccc']);
    expect(logFile('velin.2.log').readAsLinesSync(), ['line-bbb']);
    expect(logFile('velin.3.log').existsSync(), isFalse);
  });

  test('with maxFiles 1 the current file is truncated on rotation', () {
    final writer = LogFileWriter(directory: tempDir, maxBytes: 10, maxFiles: 1)
      ..open();

    writer
      ..write('line-aaa')
      ..write('line-bbb')
      ..close();

    expect(logFile('velin.log').readAsLinesSync(), ['line-bbb']);
    expect(logFile('velin.1.log').existsSync(), isFalse);
  });

  test('writes are ignored after close', () {
    final writer = LogFileWriter(directory: tempDir)..open();

    writer
      ..write('kept')
      ..close()
      ..write('dropped');

    expect(writer.isOpen, isFalse);
    expect(logFile('velin.log').readAsLinesSync(), ['kept']);
  });
}
