import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('SplitPdfState', () {
    test('uses the expected defaults', () {
      const state = SplitPdfState();

      expect(state.inputFilePath, isNull);
      expect(state.mode, SplitPdfMode.byPageCount);
      expect(state.selections, isEmpty);
      expect(state.pageCount, '');
      expect(state.outputDirectory, isNull);
      expect(state.isSubmitting, isFalse);
    });

    group('hasInputFile', () {
      test('returns false when there is no input file', () {
        const state = SplitPdfState();

        expect(state.hasInputFile, isFalse);
      });

      test('returns false for an empty path', () {
        const state = SplitPdfState(inputFilePath: '');

        expect(state.hasInputFile, isFalse);
      });

      test('returns false for whitespace', () {
        const state = SplitPdfState(inputFilePath: '   ');

        expect(state.hasInputFile, isFalse);
      });

      test('returns true for a valid path', () {
        const state = SplitPdfState(inputFilePath: '/documents/input.pdf');

        expect(state.hasInputFile, isTrue);
      });
    });

    group('hasValidOutputDirectory', () {
      test('returns false when there is no output directory', () {
        const state = SplitPdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns false for whitespace', () {
        const state = SplitPdfState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('returns true for a valid directory', () {
        const state = SplitPdfState(outputDirectory: '/documents/output');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('parsedPageCount', () {
      test('parses a valid page count', () {
        const state = SplitPdfState(pageCount: '25');

        expect(state.parsedPageCount, 25);
      });

      test('trims whitespace before parsing', () {
        const state = SplitPdfState(pageCount: ' 25 ');

        expect(state.parsedPageCount, 25);
      });

      test('returns null for an empty value', () {
        const state = SplitPdfState();

        expect(state.parsedPageCount, isNull);
      });

      test('returns null for an invalid value', () {
        const state = SplitPdfState(pageCount: 'abc');

        expect(state.parsedPageCount, isNull);
      });

      test('returns null for a decimal value', () {
        const state = SplitPdfState(pageCount: '2.5');

        expect(state.parsedPageCount, isNull);
      });
    });

    group('hasValidPageCount', () {
      test('returns true for a positive page count', () {
        const state = SplitPdfState(pageCount: '10');

        expect(state.hasValidPageCount, isTrue);
      });

      test('returns true for one page', () {
        const state = SplitPdfState(pageCount: '1');

        expect(state.hasValidPageCount, isTrue);
      });

      test('returns false for zero', () {
        const state = SplitPdfState(pageCount: '0');

        expect(state.hasValidPageCount, isFalse);
      });

      test('returns false for a negative value', () {
        const state = SplitPdfState(pageCount: '-1');

        expect(state.hasValidPageCount, isFalse);
      });

      test('returns false for invalid text', () {
        const state = SplitPdfState(pageCount: 'abc');

        expect(state.hasValidPageCount, isFalse);
      });
    });

    group('hasValidSelections', () {
      test('returns false when there are no selections', () {
        const state = SplitPdfState();

        expect(state.hasValidSelections, isFalse);
      });

      test('returns true when all selections are non-empty', () {
        const state = SplitPdfState(selections: ['1-5', '10', 'odd']);

        expect(state.hasValidSelections, isTrue);
      });

      test('returns false when a selection is empty', () {
        const state = SplitPdfState(selections: ['1-5', '']);

        expect(state.hasValidSelections, isFalse);
      });

      test('returns false when a selection contains only whitespace', () {
        const state = SplitPdfState(selections: ['1-5', '   ']);

        expect(state.hasValidSelections, isFalse);
      });
    });

    group('hasValidModeConfig', () {
      test('uses page count validation for page count mode', () {
        const valid = SplitPdfState(
          mode: SplitPdfMode.byPageCount,
          pageCount: '10',
        );
        const invalid = SplitPdfState(
          mode: SplitPdfMode.byPageCount,
          pageCount: '0',
        );

        expect(valid.hasValidModeConfig, isTrue);
        expect(invalid.hasValidModeConfig, isFalse);
      });

      test('uses selection validation for selection mode', () {
        const valid = SplitPdfState(
          mode: SplitPdfMode.bySelection,
          selections: ['1-5'],
        );
        const invalid = SplitPdfState(mode: SplitPdfMode.bySelection);

        expect(valid.hasValidModeConfig, isTrue);
        expect(invalid.hasValidModeConfig, isFalse);
      });

      test('always accepts extract all pages mode', () {
        const state = SplitPdfState(mode: SplitPdfMode.extractAllPages);

        expect(state.hasValidModeConfig, isTrue);
      });
    });

    group('canSplit', () {
      test('returns false without an input file', () {
        const state = SplitPdfState(
          pageCount: '10',
          outputDirectory: '/documents/output',
        );

        expect(state.canSplit, isFalse);
      });

      test('returns false without an output directory', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
        );

        expect(state.canSplit, isFalse);
      });

      test('returns false with invalid mode configuration', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '0',
          outputDirectory: '/documents/output',
        );

        expect(state.canSplit, isFalse);
      });

      test('returns false while submitting', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        expect(state.canSplit, isFalse);
      });

      test('returns true for valid page count mode', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
        );

        expect(state.canSplit, isTrue);
      });

      test('returns true for valid selection mode', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.bySelection,
          selections: ['1-5', '10'],
          outputDirectory: '/documents/output',
        );

        expect(state.canSplit, isTrue);
      });

      test('returns true for extract all pages mode', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.extractAllPages,
          outputDirectory: '/documents/output',
        );

        expect(state.canSplit, isTrue);
      });
    });

    group('copyWith', () {
      test('replaces provided values', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.byPageCount,
          selections: ['1-5'],
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        );

        final copied = state.copyWith(
          inputFilePath: '/documents/other.pdf',
          mode: SplitPdfMode.bySelection,
          selections: ['2-4'],
          pageCount: '20',
          outputDirectory: '/documents/new-output',
          isSubmitting: true,
        );

        expect(
          copied,
          const SplitPdfState(
            inputFilePath: '/documents/other.pdf',
            mode: SplitPdfMode.bySelection,
            selections: ['2-4'],
            pageCount: '20',
            outputDirectory: '/documents/new-output',
            isSubmitting: true,
          ),
        );
      });

      test('preserves unspecified values', () {
        const state = SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.bySelection,
          selections: ['1-5'],
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        final copied = state.copyWith();

        expect(copied, state);
      });

      test('can explicitly clear nullable input file path', () {
        const state = SplitPdfState(inputFilePath: '/documents/input.pdf');

        final copied = state.copyWith(inputFilePath: null);

        expect(copied.inputFilePath, isNull);
      });

      test('can explicitly clear nullable output directory', () {
        const state = SplitPdfState(outputDirectory: '/documents/output');

        final copied = state.copyWith(outputDirectory: null);

        expect(copied.outputDirectory, isNull);
      });
    });

    test('supports value equality', () {
      const first = SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.bySelection,
        selections: ['1-5', '10'],
        pageCount: '10',
        outputDirectory: '/documents/output',
        isSubmitting: false,
      );
      const second = SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.bySelection,
        selections: ['1-5', '10'],
        pageCount: '10',
        outputDirectory: '/documents/output',
        isSubmitting: false,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different values are not equal', () {
      const first = SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '10',
      );
      const second = SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '20',
      );

      expect(first, isNot(second));
    });

    test('different selection lists are not equal', () {
      const first = SplitPdfState(selections: ['1-5']);
      const second = SplitPdfState(selections: ['1-6']);

      expect(first, isNot(second));
    });
  });
}
