import 'package:flutter_test/flutter_test.dart';

import 'package:velin/features/tools/sub_features/decrypt_pdf/decrypt_pdf.dart';

void main() {
  group('DecryptPdfToolInput', () {
    test('uses an empty password by default', () {
      const input = DecryptPdfToolInput(
        filePath: '/documents/protected.pdf',
        outputFilePath: '/documents/unlocked.pdf',
      );

      expect(input.filePath, '/documents/protected.pdf');
      expect(input.outputFilePath, '/documents/unlocked.pdf');
      expect(input.password, isEmpty);
    });

    test('accepts a password', () {
      const input = DecryptPdfToolInput(
        filePath: '/documents/protected.pdf',
        outputFilePath: '/documents/unlocked.pdf',
        password: 'secret',
      );

      expect(input.password, 'secret');
    });

    group('copyWith', () {
      test('preserves existing password when no value is provided', () {
        const input = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        final result = input.copyWith();

        expect(result, input);
      });

      test('updates the password', () {
        const input = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        final result = input.copyWith(password: 'new-secret');

        expect(result.filePath, input.filePath);
        expect(result.outputFilePath, input.outputFilePath);
        expect(result.password, 'new-secret');
      });

      test('preserves file paths when updating the password', () {
        const input = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
        );

        final result = input.copyWith(password: 'secret');

        expect(result.filePath, '/documents/protected.pdf');
        expect(result.outputFilePath, '/documents/unlocked.pdf');
        expect(result.password, 'secret');
      });
    });

    group('equality', () {
      test('inputs with the same values are equal', () {
        const first = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        const second = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('inputs with different values are not equal', () {
        const first = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        const second = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'different',
        );

        expect(first, isNot(second));
      });

      test('inputs with different file paths are not equal', () {
        const first = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
        );

        const second = DecryptPdfToolInput(
          filePath: '/documents/other.pdf',
          outputFilePath: '/documents/unlocked.pdf',
        );

        expect(first, isNot(second));
      });

      test('inputs with different output paths are not equal', () {
        const first = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
        );

        const second = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/result.pdf',
        );

        expect(first, isNot(second));
      });
    });

    group('toDecryptPdfInput', () {
      test('maps values to engine input', () {
        const input = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
          password: 'secret',
        );

        final result = input.toDecryptPdfInput();

        expect(result.inputFile.path, '/documents/protected.pdf');
        expect(result.outputFile.path, '/documents/unlocked.pdf');
        expect(result.password, 'secret');
      });

      test('maps an empty password', () {
        const input = DecryptPdfToolInput(
          filePath: '/documents/protected.pdf',
          outputFilePath: '/documents/unlocked.pdf',
        );

        final result = input.toDecryptPdfInput();

        expect(result.inputFile.path, '/documents/protected.pdf');
        expect(result.outputFile.path, '/documents/unlocked.pdf');
        expect(result.password, isEmpty);
      });
    });
  });
}
