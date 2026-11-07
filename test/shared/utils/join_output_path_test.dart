import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:velin/shared/utils/utils.dart';

void main() {
  group('joinOutputPath', () {
    test('joins folder and file name with the platform separator', () {
      expect(joinOutputPath('/out', 'a.pdf'), p.join('/out', 'a.pdf'));
    });

    test('strips trailing separators so they are never doubled', () {
      expect(joinOutputPath('/out///', 'a.pdf'), p.join('/out', 'a.pdf'));
      expect(joinOutputPath(r'C:\out\', 'a.pdf'), p.join(r'C:\out', 'a.pdf'));
    });

    test('trims surrounding whitespace', () {
      expect(joinOutputPath('  /out  ', ' a.pdf '), p.join('/out', 'a.pdf'));
    });
  });
}
