import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/safe_file_writer.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('velin_multi_'));
  tearDown(() => dir.deleteSync(recursive: true));

  File file(String name) => File(p.join(dir.path, name));

  group('discardOnCancel', () {
    test('deletes the files written so far when cancelled', () async {
      final written = <File>[];

      await expectLater(
        discardOnCancel(written, () async {
          written.add(file('a.pdf')..writeAsStringSync('a'));
          written.add(file('b.pdf')..writeAsStringSync('b'));
          throw const CancelledFailure();
        }),
        throwsA(isA<CancelledFailure>()),
      );

      expect(dir.listSync(), isEmpty);
    });

    test('keeps the files for other failures', () async {
      final written = <File>[];

      await expectLater(
        discardOnCancel(written, () async {
          written.add(file('a.pdf')..writeAsStringSync('a'));
          throw const DiskFullFailure();
        }),
        throwsA(isA<DiskFullFailure>()),
      );

      expect(file('a.pdf').existsSync(), isTrue);
    });
  });

  group('confirmOverwrites', () {
    test('does not ask when nothing exists', () async {
      var asked = false;

      await confirmOverwrites([file('new.pdf')], (_) async => asked = true);

      expect(asked, isFalse);
    });

    test('asks with only the existing files', () async {
      file('old.pdf').writeAsStringSync('x');
      List<File>? existing;

      await confirmOverwrites([file('old.pdf'), file('new.pdf')], (
        files,
      ) async {
        existing = files;
        return true;
      });

      expect(existing!.map((f) => p.basename(f.path)), ['old.pdf']);
    });

    test('throws CancelledFailure when declined', () async {
      file('old.pdf').writeAsStringSync('x');

      await expectLater(
        confirmOverwrites([file('old.pdf')], (_) async => false),
        throwsA(isA<CancelledFailure>()),
      );
    });
  });
}
