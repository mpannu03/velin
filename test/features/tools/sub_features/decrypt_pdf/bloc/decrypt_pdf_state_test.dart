import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:velin/features/tools/sub_features/decrypt_pdf/decrypt_pdf.dart';

void main() {
  group('DecryptPdfState', () {
    test('has expected default values', () {
      const state = DecryptPdfState();

      expect(state.inputFilePath, isNull);
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.password, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.hasInputFile, isFalse);
      expect(state.hasValidOutputDirectory, isFalse);
      expect(state.hasValidOutputFileName, isFalse);
      expect(state.hasPassword, isFalse);
      expect(state.canDecrypt, isFalse);
    });

    group('hasInputFile', () {
      test('returns false for null', () {
        const state = DecryptPdfState();

        expect(state.hasInputFile, isFalse);
      });

      test('returns false for empty path', () {
        const state = DecryptPdfState(inputFilePath: '');

        expect(state.hasInputFile, isFalse);
      });

      test('returns false for whitespace-only path', () {
        const state = DecryptPdfState(inputFilePath: '   ');

        expect(state.hasInputFile, isFalse);
      });

      test('returns true for a non-empty path', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
        );

        expect(state.hasInputFile, isTrue);
      });
    });

    group('hasValidOutputDirectory', () {
      test('returns false for null', () {
        const state = DecryptPdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false for empty directory', () {
        const state = DecryptPdfState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false for whitespace-only directory', () {
        const state = DecryptPdfState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns true for a non-empty directory', () {
        const state = DecryptPdfState(outputDirectory: '/documents/output');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidOutputFileName', () {
      test('returns false for null', () {
        const state = DecryptPdfState();

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false for empty filename', () {
        const state = DecryptPdfState(outputFileName: '');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false for whitespace-only filename', () {
        const state = DecryptPdfState(outputFileName: '   ');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns true for a non-empty filename', () {
        const state = DecryptPdfState(outputFileName: 'unlocked.pdf');

        expect(state.hasValidOutputFileName, isTrue);
      });
    });

    group('hasPassword', () {
      test('returns false for an empty password', () {
        const state = DecryptPdfState(password: '');

        expect(state.hasPassword, isFalse);
      });

      test('returns false for whitespace-only password', () {
        const state = DecryptPdfState(password: '   ');

        expect(state.hasPassword, isFalse);
      });

      test('returns true for a non-empty password', () {
        const state = DecryptPdfState(password: 'secret');

        expect(state.hasPassword, isTrue);
      });
    });

    group('canDecrypt', () {
      test('returns true with valid input and output values', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
        );

        expect(state.canDecrypt, isTrue);
      });

      test('does not require a password', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          password: '',
        );

        expect(state.canDecrypt, isTrue);
      });

      test('returns false while submitting', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          isSubmitting: true,
        );

        expect(state.canDecrypt, isFalse);
      });

      test('returns false when input file is missing', () {
        const state = DecryptPdfState(
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
        );

        expect(state.canDecrypt, isFalse);
      });

      test('returns false when output directory is missing', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputFileName: 'unlocked.pdf',
        );

        expect(state.canDecrypt, isFalse);
      });

      test('returns false when output filename is missing', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
        );

        expect(state.canDecrypt, isFalse);
      });
    });

    group('toolInput', () {
      test('creates input with trimmed paths and password', () {
        const state = DecryptPdfState(
          inputFilePath: '  /documents/protected.pdf  ',
          outputDirectory: '  /documents/output  ',
          outputFileName: '  unlocked.pdf  ',
          password: 'secret',
        );

        final input = state.toolInput;

        expect(input.filePath, '/documents/protected.pdf');
        expect(
          input.outputFilePath,
          '/documents/output${Platform.pathSeparator}unlocked.pdf',
        );
        expect(input.password, 'secret');
      });

      test('removes trailing directory separators', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output///',
          outputFileName: 'unlocked.pdf',
        );

        final input = state.toolInput;

        expect(
          input.outputFilePath,
          '/documents/output${Platform.pathSeparator}unlocked.pdf',
        );
      });

      test('handles backslash trailing separators', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: r'C:\documents\output\\',
          outputFileName: 'unlocked.pdf',
        );

        final input = state.toolInput;

        expect(
          input.outputFilePath,
          'C:\\documents\\output'
          '${Platform.pathSeparator}'
          'unlocked.pdf',
        );
      });
    });

    group('copyWith', () {
      test('preserves existing values when no changes are provided', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          password: 'secret',
          isSubmitting: true,
        );

        final result = state.copyWith();

        expect(result, state);
      });

      test('updates provided values', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          password: 'secret',
        );

        final result = state.copyWith(
          inputFilePath: '/other/protected.pdf',
          outputDirectory: '/other',
          outputFileName: 'result.pdf',
          password: 'new-secret',
          isSubmitting: true,
        );

        expect(result.inputFilePath, '/other/protected.pdf');
        expect(result.outputDirectory, '/other');
        expect(result.outputFileName, 'result.pdf');
        expect(result.password, 'new-secret');
        expect(result.isSubmitting, isTrue);
      });

      test('can explicitly clear nullable values', () {
        const state = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
        );

        final result = state.copyWith(
          inputFilePath: null,
          outputDirectory: null,
          outputFileName: null,
        );

        expect(result.inputFilePath, isNull);
        expect(result.outputDirectory, isNull);
        expect(result.outputFileName, isNull);
      });

      test('preserves password when null is provided', () {
        const state = DecryptPdfState(password: 'secret');

        final result = state.copyWith();

        expect(result.password, 'secret');
      });
    });

    group('equality', () {
      test('states with the same values are equal', () {
        const first = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          password: 'secret',
          isSubmitting: true,
        );

        const second = DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'unlocked.pdf',
          password: 'secret',
          isSubmitting: true,
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('states with different values are not equal', () {
        const first = DecryptPdfState(password: 'secret');
        const second = DecryptPdfState(password: 'different');

        expect(first, isNot(second));
      });
    });
  });
}
