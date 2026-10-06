import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('RotatePdfState', () {
    test('uses expected defaults', () {
      const state = RotatePdfState();

      expect(state.inputFilePath, isNull);
      expect(state.direction, RotatePdfDirection.clockwise90);
      expect(state.scope, RotatePdfPageScope.allPages);
      expect(state.selection, '');
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('validates input file', () {
      expect(const RotatePdfState().hasInputFile, isFalse);
      expect(const RotatePdfState(inputFilePath: '').hasInputFile, isFalse);
      expect(const RotatePdfState(inputFilePath: '   ').hasInputFile, isFalse);
      expect(
        const RotatePdfState(inputFilePath: '/documents/sample.pdf')
            .hasInputFile,
        isTrue,
      );
    });

    test('validates output directory', () {
      expect(const RotatePdfState().hasValidOutputDirectory, isFalse);
      expect(
        const RotatePdfState(outputDirectory: '').hasValidOutputDirectory,
        isFalse,
      );
      expect(
        const RotatePdfState(outputDirectory: '   ').hasValidOutputDirectory,
        isFalse,
      );
      expect(
        const RotatePdfState(outputDirectory: '/documents/output')
            .hasValidOutputDirectory,
        isTrue,
      );
    });

    test('validates output file name', () {
      expect(const RotatePdfState().hasValidOutputFileName, isFalse);
      expect(
        const RotatePdfState(outputFileName: '').hasValidOutputFileName,
        isFalse,
      );
      expect(
        const RotatePdfState(outputFileName: '   ').hasValidOutputFileName,
        isFalse,
      );
      expect(
        const RotatePdfState(outputFileName: 'rotated.pdf')
            .hasValidOutputFileName,
        isTrue,
      );
    });

    test('validates page selection', () {
      expect(const RotatePdfState().hasValidSelection, isFalse);
      expect(const RotatePdfState(selection: '   ').hasValidSelection, isFalse);
      expect(const RotatePdfState(selection: '1-5').hasValidSelection, isTrue);
    });

    test('allows all pages without a selection', () {
      const state = RotatePdfState(scope: RotatePdfPageScope.allPages);

      expect(state.hasValidScopeConfig, isTrue);
    });

    test('requires selection for selected pages scope', () {
      expect(
        const RotatePdfState(scope: RotatePdfPageScope.selectedPages)
            .hasValidScopeConfig,
        isFalse,
      );

      expect(
        const RotatePdfState(
          scope: RotatePdfPageScope.selectedPages,
          selection: '1-5',
        ).hasValidScopeConfig,
        isTrue,
      );
    });

    test('canRotate is false when required input is missing', () {
      const state = RotatePdfState(
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      expect(state.canRotate, isFalse);
    });

    test('canRotate is false when output directory is missing', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputFileName: 'rotated.pdf',
      );

      expect(state.canRotate, isFalse);
    });

    test('canRotate is false when output file name is missing', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
      );

      expect(state.canRotate, isFalse);
    });

    test('canRotate is false when selected pages have no selection', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        scope: RotatePdfPageScope.selectedPages,
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      expect(state.canRotate, isFalse);
    });

    test('canRotate is false while submitting', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: true,
      );

      expect(state.canRotate, isFalse);
    });

    test('canRotate is true with a valid all-pages configuration', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      expect(state.canRotate, isTrue);
    });

    test('canRotate is true with a valid selected-pages configuration', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        scope: RotatePdfPageScope.selectedPages,
        selection: '1-5,8',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      expect(state.canRotate, isTrue);
    });

    test('copyWith updates all supplied values', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.allPages,
        selection: '',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: false,
      );

      final updated = state.copyWith(
        inputFilePath: '/documents/other.pdf',
        direction: RotatePdfDirection.counterClockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '2,4,6',
        outputDirectory: '/documents/other-output',
        outputFileName: 'other.pdf',
        isSubmitting: true,
      );

      expect(
        updated,
        const RotatePdfState(
          inputFilePath: '/documents/other.pdf',
          direction: RotatePdfDirection.counterClockwise90,
          scope: RotatePdfPageScope.selectedPages,
          selection: '2,4,6',
          outputDirectory: '/documents/other-output',
          outputFileName: 'other.pdf',
          isSubmitting: true,
        ),
      );
    });

    test('copyWith preserves unspecified values', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.upsideDown,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1-3',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: true,
      );

      expect(state.copyWith(), state);
    });

    test('copyWith can clear nullable fields', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      final updated = state.copyWith(
        inputFilePath: null,
        outputDirectory: null,
        outputFileName: null,
      );

      expect(updated.inputFilePath, isNull);
      expect(updated.outputDirectory, isNull);
      expect(updated.outputFileName, isNull);
    });

    test('supports equality for identical values', () {
      const first = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.upsideDown,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1,3,5',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: false,
      );

      const second = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.upsideDown,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1,3,5',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: false,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('distinguishes different values', () {
      const state = RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      );

      expect(
        state,
        isNot(
          const RotatePdfState(
            inputFilePath: '/documents/sample.pdf',
            direction: RotatePdfDirection.upsideDown,
            outputDirectory: '/documents/output',
            outputFileName: 'rotated.pdf',
          ),
        ),
      );
    });
  });
}
