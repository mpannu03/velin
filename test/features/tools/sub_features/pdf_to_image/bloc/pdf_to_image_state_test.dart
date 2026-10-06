import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('PdfToImageState', () {
    test('uses expected defaults', () {
      const state = PdfToImageState();

      expect(state.inputFilePath, isNull);
      expect(state.scope, PdfToImagePageScope.allPages);
      expect(state.selection, '');
      expect(state.format, PdfImageFormat.png);
      expect(state.colorMode, PdfImageColorMode.color);
      expect(state.dpi, 150);
      expect(state.quality, 90);
      expect(state.outputDirectory, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('supportsQuality is false for PNG', () {
      const state = PdfToImageState(format: PdfImageFormat.png);

      expect(state.supportsQuality, isFalse);
    });

    test('supportsQuality is true for JPEG', () {
      const state = PdfToImageState(format: PdfImageFormat.jpeg);

      expect(state.supportsQuality, isTrue);
    });

    test('supportsQuality is true for WebP', () {
      const state = PdfToImageState(format: PdfImageFormat.webp);

      expect(state.supportsQuality, isTrue);
    });

    group('hasInputFile', () {
      test('is false when input file is null', () {
        const state = PdfToImageState();

        expect(state.hasInputFile, isFalse);
      });

      test('is false when input file is empty', () {
        const state = PdfToImageState(inputFilePath: '');

        expect(state.hasInputFile, isFalse);
      });

      test('is false when input file contains only whitespace', () {
        const state = PdfToImageState(inputFilePath: '   ');

        expect(state.hasInputFile, isFalse);
      });

      test('is true when input file is valid', () {
        const state = PdfToImageState(inputFilePath: '/documents/input.pdf');

        expect(state.hasInputFile, isTrue);
      });
    });

    group('hasValidOutputDirectory', () {
      test('is false when output directory is null', () {
        const state = PdfToImageState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when output directory is empty', () {
        const state = PdfToImageState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when output directory contains only whitespace', () {
        const state = PdfToImageState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is true when output directory is valid', () {
        const state = PdfToImageState(outputDirectory: '/documents/output');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidSelection', () {
      test('is false when selection is empty', () {
        const state = PdfToImageState();

        expect(state.hasValidSelection, isFalse);
      });

      test('is false when selection contains only whitespace', () {
        const state = PdfToImageState(selection: '   ');

        expect(state.hasValidSelection, isFalse);
      });

      test('is true when selection is valid', () {
        const state = PdfToImageState(selection: '1-5, 8, last');

        expect(state.hasValidSelection, isTrue);
      });
    });

    group('hasValidScopeConfig', () {
      test('is true for all pages without a selection', () {
        const state = PdfToImageState(scope: PdfToImagePageScope.allPages);

        expect(state.hasValidScopeConfig, isTrue);
      });

      test('is false for selected pages without a selection', () {
        const state = PdfToImageState(scope: PdfToImagePageScope.selectedPages);

        expect(state.hasValidScopeConfig, isFalse);
      });

      test('is true for selected pages with a selection', () {
        const state = PdfToImageState(
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
        );

        expect(state.hasValidScopeConfig, isTrue);
      });
    });

    group('canConvert', () {
      test('is false without an input file', () {
        const state = PdfToImageState(outputDirectory: '/documents/output');

        expect(state.canConvert, isFalse);
      });

      test('is false without an output directory', () {
        const state = PdfToImageState(inputFilePath: '/documents/input.pdf');

        expect(state.canConvert, isFalse);
      });

      test('is false when selected-pages scope has no selection', () {
        const state = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          outputDirectory: '/documents/output',
        );

        expect(state.canConvert, isFalse);
      });

      test('is true when all-pages scope has valid input and output', () {
        const state = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
        );

        expect(state.canConvert, isTrue);
      });

      test('is true when selected-pages scope has a valid selection', () {
        const state = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          outputDirectory: '/documents/output',
        );

        expect(state.canConvert, isTrue);
      });

      test('is false while submitting', () {
        const state = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        expect(state.canConvert, isFalse);
      });
    });

    group('copyWith', () {
      test('preserves existing values when no arguments are provided', () {
        const state = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        final copy = state.copyWith();

        expect(copy, state);
      });

      test('updates input file path', () {
        const state = PdfToImageState(inputFilePath: '/documents/input.pdf');

        final copy = state.copyWith(inputFilePath: '/documents/other.pdf');

        expect(copy.inputFilePath, '/documents/other.pdf');
      });

      test('can clear input file path', () {
        const state = PdfToImageState(inputFilePath: '/documents/input.pdf');

        final copy = state.copyWith(inputFilePath: null);

        expect(copy.inputFilePath, isNull);
      });

      test('updates scope', () {
        const state = PdfToImageState();

        final copy = state.copyWith(scope: PdfToImagePageScope.selectedPages);

        expect(copy.scope, PdfToImagePageScope.selectedPages);
      });

      test('updates selection', () {
        const state = PdfToImageState();

        final copy = state.copyWith(selection: '1-5');

        expect(copy.selection, '1-5');
      });

      test('updates format', () {
        const state = PdfToImageState();

        final copy = state.copyWith(format: PdfImageFormat.webp);

        expect(copy.format, PdfImageFormat.webp);
      });

      test('updates color mode', () {
        const state = PdfToImageState();

        final copy = state.copyWith(colorMode: PdfImageColorMode.grayscale);

        expect(copy.colorMode, PdfImageColorMode.grayscale);
      });

      test('updates DPI', () {
        const state = PdfToImageState();

        final copy = state.copyWith(dpi: 600);

        expect(copy.dpi, 600);
      });

      test('updates quality', () {
        const state = PdfToImageState();

        final copy = state.copyWith(quality: 75);

        expect(copy.quality, 75);
      });

      test('updates output directory', () {
        const state = PdfToImageState();

        final copy = state.copyWith(outputDirectory: '/documents/output');

        expect(copy.outputDirectory, '/documents/output');
      });

      test('can clear output directory', () {
        const state = PdfToImageState(outputDirectory: '/documents/output');

        final copy = state.copyWith(outputDirectory: null);

        expect(copy.outputDirectory, isNull);
      });

      test('updates submitting state', () {
        const state = PdfToImageState();

        final copy = state.copyWith(isSubmitting: true);

        expect(copy.isSubmitting, isTrue);
      });

      test('updates multiple values together', () {
        const state = PdfToImageState();

        final copy = state.copyWith(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 75,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        expect(copy.inputFilePath, '/documents/input.pdf');
        expect(copy.scope, PdfToImagePageScope.selectedPages);
        expect(copy.selection, '1-5');
        expect(copy.format, PdfImageFormat.jpeg);
        expect(copy.colorMode, PdfImageColorMode.grayscale);
        expect(copy.dpi, 300);
        expect(copy.quality, 75);
        expect(copy.outputDirectory, '/documents/output');
        expect(copy.isSubmitting, isTrue);
      });
    });

    group('equality', () {
      test('equal states are equal', () {
        const first = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        const second = PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('identical states are equal', () {
        const state = PdfToImageState();

        expect(state == state, isTrue);
      });

      test('different input file paths are not equal', () {
        const first = PdfToImageState(inputFilePath: '/documents/first.pdf');
        const second = PdfToImageState(inputFilePath: '/documents/second.pdf');

        expect(first, isNot(second));
      });

      test('different scopes are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(
          scope: PdfToImagePageScope.selectedPages,
        );

        expect(first, isNot(second));
      });

      test('different selections are not equal', () {
        const first = PdfToImageState(selection: '1-5');
        const second = PdfToImageState(selection: '1-10');

        expect(first, isNot(second));
      });

      test('different formats are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(format: PdfImageFormat.jpeg);

        expect(first, isNot(second));
      });

      test('different color modes are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(colorMode: PdfImageColorMode.grayscale);

        expect(first, isNot(second));
      });

      test('different DPI values are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(dpi: 300);

        expect(first, isNot(second));
      });

      test('different quality values are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(quality: 80);

        expect(first, isNot(second));
      });

      test('different output directories are not equal', () {
        const first = PdfToImageState(outputDirectory: '/documents/first');
        const second = PdfToImageState(outputDirectory: '/documents/second');

        expect(first, isNot(second));
      });

      test('different submitting states are not equal', () {
        const first = PdfToImageState();
        const second = PdfToImageState(isSubmitting: true);

        expect(first, isNot(second));
      });
    });
  });
}
