import 'package:flutter_test/flutter_test.dart';

import 'package:velin/features/tools/tools.dart';

void main() {
  group('MergePdfState', () {
    test('has the expected defaults', () {
      const state = MergePdfState();

      expect(state.inputs, isEmpty);
      expect(state.outputFileName, 'merged.pdf');
      expect(state.outputDirectory, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('hasInputFiles reflects whether inputs exist', () {
      expect(const MergePdfState().hasInputFiles, isFalse);

      expect(
        MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
        ).hasInputFiles,
        isTrue,
      );
    });

    group('hasValidOutputDirectory', () {
      test('is false when directory is null', () {
        const state = MergePdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when directory is empty', () {
        const state = MergePdfState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when directory contains only whitespace', () {
        const state = MergePdfState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is true when directory contains a non-whitespace value', () {
        const state = MergePdfState(outputDirectory: '/documents');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidOutputFileName', () {
      test('is true for the default file name', () {
        const state = MergePdfState();

        expect(state.hasValidOutputFileName, isTrue);
      });

      test('is false when file name is empty', () {
        const state = MergePdfState(outputFileName: '');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('is false when file name contains only whitespace', () {
        const state = MergePdfState(outputFileName: '   ');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('is true when file name contains a non-whitespace value', () {
        const state = MergePdfState(outputFileName: 'merged.pdf');

        expect(state.hasValidOutputFileName, isTrue);
      });
    });

    group('canMerge', () {
      test('is false when there are no input files', () {
        const state = MergePdfState(outputDirectory: '/documents');

        expect(state.canMerge, isFalse);
      });

      test('is false when output directory is invalid', () {
        const state = MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
        );

        expect(state.canMerge, isFalse);
      });

      test('is false when output file name is invalid', () {
        const state = MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
          outputDirectory: '/documents',
          outputFileName: '   ',
        );

        expect(state.canMerge, isFalse);
      });

      test('is false while submitting', () {
        const state = MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
          outputDirectory: '/documents',
          isSubmitting: true,
        );

        expect(state.canMerge, isFalse);
      });

      test('is true when all merge requirements are valid', () {
        const state = MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
          outputDirectory: '/documents',
          outputFileName: 'merged.pdf',
        );

        expect(state.canMerge, isTrue);
      });
    });

    group('copyWith', () {
      test('preserves values that are not changed', () {
        const state = MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/first.pdf')],
          outputFileName: 'combined.pdf',
          outputDirectory: '/documents',
          isSubmitting: true,
        );

        final result = state.copyWith();

        expect(result, state);
      });

      test('updates all supplied values', () {
        const state = MergePdfState();

        final inputs = [
          MergePdfToolInput(filePath: '/documents/first.pdf'),
          MergePdfToolInput(filePath: '/documents/second.pdf'),
        ];

        final result = state.copyWith(
          inputs: inputs,
          outputFileName: 'combined.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        expect(result.inputs, inputs);
        expect(result.outputFileName, 'combined.pdf');
        expect(result.outputDirectory, '/documents/output');
        expect(result.isSubmitting, isTrue);
      });

      test('explicitly clears output directory with null', () {
        const state = MergePdfState(outputDirectory: '/documents');

        final result = state.copyWith(outputDirectory: null);

        expect(result.outputDirectory, isNull);
      });

      test('preserves output directory when not supplied', () {
        const state = MergePdfState(outputDirectory: '/documents');

        final result = state.copyWith();

        expect(result.outputDirectory, '/documents');
      });

      test('updates inputs', () {
        const state = MergePdfState();

        final inputs = [MergePdfToolInput(filePath: '/documents/first.pdf')];

        final result = state.copyWith(inputs: inputs);

        expect(result.inputs, inputs);
      });

      test('updates output file name', () {
        const state = MergePdfState();

        final result = state.copyWith(outputFileName: 'combined.pdf');

        expect(result.outputFileName, 'combined.pdf');
      });

      test('updates submitting state', () {
        const state = MergePdfState();

        final result = state.copyWith(isSubmitting: true);

        expect(result.isSubmitting, isTrue);
      });
    });

    test('supports equality for equivalent states', () {
      const first = MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: '/documents/first.pdf'),
          MergePdfToolInput(
            filePath: '/documents/second.pdf',
            pageSelection: '1-5',
          ),
        ],
        outputFileName: 'combined.pdf',
        outputDirectory: '/documents',
        isSubmitting: true,
      );

      const second = MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: '/documents/first.pdf'),
          MergePdfToolInput(
            filePath: '/documents/second.pdf',
            pageSelection: '1-5',
          ),
        ],
        outputFileName: 'combined.pdf',
        outputDirectory: '/documents',
        isSubmitting: true,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('states with different values are not equal', () {
      const first = MergePdfState(outputDirectory: '/documents');

      const second = MergePdfState(outputDirectory: '/other');

      expect(first, isNot(second));
    });
  });
}
