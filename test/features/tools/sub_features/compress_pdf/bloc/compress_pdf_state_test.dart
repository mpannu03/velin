import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';

void main() {
  group('CompressPdfState', () {
    test('uses default values', () {
      const state = CompressPdfState();

      expect(state.inputFilePath, isNull);
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.quality, 75);
      expect(state.isSubmitting, isFalse);
    });

    group('hasInputFile', () {
      test('returns false when path is null', () {
        const state = CompressPdfState();

        expect(state.hasInputFile, isFalse);
      });

      test('returns false when path is empty', () {
        const state = CompressPdfState(inputFilePath: '');

        expect(state.hasInputFile, isFalse);
      });

      test('returns false when path contains only whitespace', () {
        const state = CompressPdfState(inputFilePath: '   ');

        expect(state.hasInputFile, isFalse);
      });

      test('returns true when path is present', () {
        const state = CompressPdfState(inputFilePath: '/documents/input.pdf');

        expect(state.hasInputFile, isTrue);
      });
    });

    group('hasValidOutputDirectory', () {
      test('returns false when directory is null', () {
        const state = CompressPdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false when directory is empty', () {
        const state = CompressPdfState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false when directory contains only whitespace', () {
        const state = CompressPdfState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns true when directory is present', () {
        const state = CompressPdfState(outputDirectory: '/documents');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidOutputFileName', () {
      test('returns false when filename is null', () {
        const state = CompressPdfState();

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false when filename is empty', () {
        const state = CompressPdfState(outputFileName: '');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false when filename contains only whitespace', () {
        const state = CompressPdfState(outputFileName: '   ');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns true when filename is present', () {
        const state = CompressPdfState(outputFileName: 'compressed.pdf');

        expect(state.hasValidOutputFileName, isTrue);
      });
    });

    group('canCompress', () {
      test('returns true when all required values are valid', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
        );

        expect(state.canCompress, isTrue);
      });

      test('returns false while submitting', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
          isSubmitting: true,
        );

        expect(state.canCompress, isFalse);
      });

      test('returns false when input file is missing', () {
        const state = CompressPdfState(
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
        );

        expect(state.canCompress, isFalse);
      });

      test('returns false when output directory is missing', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputFileName: 'compressed.pdf',
        );

        expect(state.canCompress, isFalse);
      });

      test('returns false when output filename is missing', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
        );

        expect(state.canCompress, isFalse);
      });
    });

    group('toolInput', () {
      test('trims paths and joins output path', () {
        const state = CompressPdfState(
          inputFilePath: '  /documents/input.pdf  ',
          outputDirectory: '  /documents/  ',
          outputFileName: '  compressed.pdf  ',
          quality: 60,
        );

        final input = state.toolInput;

        expect(input.filePath, '/documents/input.pdf');
        expect(
          input.outputFilePath,
          '/documents${Platform.pathSeparator}compressed.pdf',
        );
        expect(input.quality, 60);
      });

      test('removes trailing separators from output directory', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents///',
          outputFileName: 'compressed.pdf',
        );

        expect(
          state.toolInput.outputFilePath,
          '/documents${Platform.pathSeparator}compressed.pdf',
        );
      });

      test('handles Windows-style trailing separators', () {
        const state = CompressPdfState(
          inputFilePath: r'C:\documents\input.pdf',
          outputDirectory: r'C:\documents\\',
          outputFileName: 'compressed.pdf',
        );

        expect(
          state.toolInput.outputFilePath,
          'C:\\documents${Platform.pathSeparator}compressed.pdf',
        );
      });
    });

    group('copyWith', () {
      test('preserves existing values when omitted', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
          quality: 60,
          isSubmitting: true,
        );

        final result = state.copyWith();

        expect(result, state);
      });

      test('updates supplied values', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
          quality: 60,
        );

        final result = state.copyWith(
          inputFilePath: '/documents/other.pdf',
          outputDirectory: '/output',
          outputFileName: 'result.pdf',
          quality: 90,
          isSubmitting: true,
        );

        expect(result.inputFilePath, '/documents/other.pdf');
        expect(result.outputDirectory, '/output');
        expect(result.outputFileName, 'result.pdf');
        expect(result.quality, 90);
        expect(result.isSubmitting, isTrue);
      });

      test('can explicitly clear nullable values', () {
        const state = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
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
    });

    group('equality', () {
      test('equal states are equal', () {
        const first = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
          quality: 60,
        );

        const second = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'compressed.pdf',
          quality: 60,
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('different states are not equal', () {
        const first = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          quality: 60,
        );

        const second = CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          quality: 80,
        );

        expect(first, isNot(second));
      });
    });
  });
}
