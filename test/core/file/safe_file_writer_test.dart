import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('velin_safe_write_');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  File file(String name) => File(p.join(tempDir.path, name));

  List<String> leftovers() => tempDir
      .listSync(recursive: true)
      .map((e) => p.basename(e.path))
      .where((name) => name.endsWith('.tmp'))
      .toList();

  group('writeAtomically', () {
    test('creates the target with the written content', () async {
      final target = file('out.pdf');

      final result = await writeBytesAtomically(target, [1, 2, 3]);

      expect(result.path, target.path);
      expect(target.readAsBytesSync(), [1, 2, 3]);
      expect(leftovers(), isEmpty);
    });

    test('replaces an existing target', () async {
      final target = file('out.pdf')..writeAsBytesSync([9, 9]);

      await writeBytesAtomically(target, [1]);

      expect(target.readAsBytesSync(), [1]);
    });

    test('creates missing parent folders', () async {
      final target = File(p.join(tempDir.path, 'a', 'b', 'out.pdf'));

      await writeBytesAtomically(target, [1]);

      expect(target.existsSync(), isTrue);
    });

    test('leaves an existing target untouched when writing fails', () async {
      final target = file('out.pdf')..writeAsBytesSync([7, 7, 7]);

      await expectLater(
        writeAtomically(target, (temporary) async {
          await temporary.writeAsBytes([1]);
          throw const DiskFullFailure();
        }),
        throwsA(isA<DiskFullFailure>()),
      );

      expect(target.readAsBytesSync(), [7, 7, 7]);
      expect(leftovers(), isEmpty);
    });

    test('does not create the target when writing fails', () async {
      final target = file('new.pdf');

      await expectLater(
        writeAtomically(target, (_) async => throw StateError('boom')),
        throwsStateError,
      );

      expect(target.existsSync(), isFalse);
      expect(leftovers(), isEmpty);
    });
  });

  group('ensureOutputDiffersFromInputs', () {
    test('accepts a different output', () {
      expect(
        () => ensureOutputDiffersFromInputs(file('out.pdf'), [file('in.pdf')]),
        returnsNormally,
      );
    });

    test('rejects an output equal to any input', () {
      expect(
        () => ensureOutputDiffersFromInputs(file('b.pdf'), [
          file('a.pdf'),
          file('b.pdf'),
        ]),
        throwsA(isA<OutputSameAsInputFailure>()),
      );
    });

    test('compares normalized paths', () {
      final sneaky = File(p.join(tempDir.path, 'x', '..', 'in.pdf'));

      expect(
        () => ensureOutputDiffersFromInputs(sneaky, [file('in.pdf')]),
        throwsA(isA<OutputSameAsInputFailure>()),
      );
    });

    test('is case-insensitive on Windows', () {
      expect(
        () => ensureOutputDiffersFromInputs(file('IN.PDF'), [file('in.pdf')]),
        throwsA(isA<OutputSameAsInputFailure>()),
      );
    }, skip: Platform.isWindows ? false : 'Windows-only path semantics');
  });
}
