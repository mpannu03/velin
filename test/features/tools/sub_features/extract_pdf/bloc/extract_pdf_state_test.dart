import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/sub_features/extract_pdf/extract_pdf.dart';

void main() {
  group('ExtractPdfState', () {
    test('uses expected defaults', () {
      const state = ExtractPdfState();

      expect(state.filePath, isNull);
      expect(state.pageSelection, isNull);
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.isSubmitting, isFalse);
    });

    group('hasValidInputFilePath', () {
      test('returns false when file path is null', () {
        const state = ExtractPdfState();

        expect(state.hasValidInputFilePath, isFalse);
      });

      test('returns false when file path is empty', () {
        const state = ExtractPdfState(filePath: '');

        expect(state.hasValidInputFilePath, isFalse);
      });

      test('returns true when file path is present', () {
        const state = ExtractPdfState(filePath: '/documents/sample.pdf');

        expect(state.hasValidInputFilePath, isTrue);
      });

      test('does not trim the file path', () {
        const state = ExtractPdfState(filePath: ' ');

        expect(state.hasValidInputFilePath, isTrue);
      });
    });

    group('hasValidOutputDirectory', () {
      test('returns false when directory is null', () {
        const state = ExtractPdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false when directory is empty', () {
        const state = ExtractPdfState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns true when directory is present', () {
        const state = ExtractPdfState(outputDirectory: '/documents/output');

        expect(state.hasValidOutputDirectory, isTrue);
      });

      test('does not trim the output directory', () {
        const state = ExtractPdfState(outputDirectory: ' ');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidOutputFileName', () {
      test('returns false when file name is null', () {
        const state = ExtractPdfState();

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false when file name is empty', () {
        const state = ExtractPdfState(outputFileName: '');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns false when file name contains only whitespace', () {
        const state = ExtractPdfState(outputFileName: '   ');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('returns true when file name contains non-whitespace text', () {
        const state = ExtractPdfState(outputFileName: 'extracted.pdf');

        expect(state.hasValidOutputFileName, isTrue);
      });

      test('returns true when file name contains surrounding whitespace', () {
        const state = ExtractPdfState(outputFileName: ' extracted.pdf ');

        expect(state.hasValidOutputFileName, isTrue);
      });
    });

    group('canExtract', () {
      test('returns false when input file is missing', () {
        const state = ExtractPdfState(
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
        );

        expect(state.canExtract, isFalse);
      });

      test('returns false when output directory is missing', () {
        const state = ExtractPdfState(
          filePath: '/documents/source.pdf',
          outputFileName: 'extracted.pdf',
        );

        expect(state.canExtract, isFalse);
      });

      test('returns false when output file name is missing', () {
        const state = ExtractPdfState(
          filePath: '/documents/source.pdf',
          outputDirectory: '/documents',
        );

        expect(state.canExtract, isFalse);
      });

      test('returns true when all required values are valid', () {
        const state = ExtractPdfState(
          filePath: '/documents/source.pdf',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
        );

        expect(state.canExtract, isTrue);
      });
    });

    group('copyWith', () {
      const state = ExtractPdfState(
        filePath: '/documents/source.pdf',
        pageSelection: '1-5',
        outputDirectory: '/documents/output',
        outputFileName: 'extracted.pdf',
        isSubmitting: true,
      );

      test('updates supplied values', () {
        final updated = state.copyWith(
          filePath: '/documents/other.pdf',
          pageSelection: '2,4,6',
          outputDirectory: '/documents/new',
          outputFileName: 'pages.pdf',
          isSubmitting: false,
        );

        expect(
          updated,
          const ExtractPdfState(
            filePath: '/documents/other.pdf',
            pageSelection: '2,4,6',
            outputDirectory: '/documents/new',
            outputFileName: 'pages.pdf',
            isSubmitting: false,
          ),
        );
      });

      test('preserves values that are not supplied', () {
        final updated = state.copyWith();

        expect(updated, state);
      });

      test('can explicitly set nullable values to null', () {
        final updated = state.copyWith(
          filePath: null,
          pageSelection: null,
          outputDirectory: null,
          outputFileName: null,
        );

        expect(updated.filePath, isNull);
        expect(updated.pageSelection, isNull);
        expect(updated.outputDirectory, isNull);
        expect(updated.outputFileName, isNull);
        expect(updated.isSubmitting, isTrue);
      });

      test('updates only isSubmitting', () {
        final updated = state.copyWith(isSubmitting: false);

        expect(updated.filePath, state.filePath);
        expect(updated.pageSelection, state.pageSelection);
        expect(updated.outputDirectory, state.outputDirectory);
        expect(updated.outputFileName, state.outputFileName);
        expect(updated.isSubmitting, isFalse);
      });
    });

    group('equality', () {
      test('considers identical states equal', () {
        const first = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        );
        const second = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        );

        expect(first, equals(second));
      });

      test('considers states with different values unequal', () {
        const first = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
        );
        const second = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '2-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
        );

        expect(first, isNot(equals(second)));
      });

      test('equal states have the same hash code', () {
        const first = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        );
        const second = ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-5',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        );

        expect(first.hashCode, equals(second.hashCode));
      });
    });
  });
}
