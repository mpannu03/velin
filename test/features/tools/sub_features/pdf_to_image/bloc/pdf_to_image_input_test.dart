import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('PdfToImagePageScope', () {
    test('allPages does not require selection', () {
      expect(PdfToImagePageScope.allPages.requiresSelection, isFalse);
    });

    test('selectedPages requires selection', () {
      expect(PdfToImagePageScope.selectedPages.requiresSelection, isTrue);
    });
  });

  group('PdfToImageToolInput', () {
    test('has expected defaults', () {
      const input = PdfToImageToolInput(filePath: '/documents/input.pdf');

      expect(input.filePath, '/documents/input.pdf');
      expect(input.scope, PdfToImagePageScope.allPages);
      expect(input.selection, '');
      expect(input.format, PdfImageFormat.png);
      expect(input.colorMode, PdfImageColorMode.color);
      expect(input.dpi, 150);
      expect(input.quality, 90);
    });

    test('defines supported DPI values', () {
      expect(PdfToImageToolInput.supportedDpi, [72, 150, 300, 600]);
    });

    test('supports quality for JPEG', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        format: PdfImageFormat.jpeg,
      );

      expect(input.supportsQuality, isTrue);
    });

    test('supports quality for WebP', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        format: PdfImageFormat.webp,
      );

      expect(input.supportsQuality, isTrue);
    });

    test('does not support quality for PNG', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        format: PdfImageFormat.png,
      );

      expect(input.supportsQuality, isFalse);
    });

    group('parsedSelection', () {
      test('returns null for all pages', () {
        const input = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.allPages,
          selection: '1-5',
        );

        expect(input.parsedSelection, isNull);
      });

      test('throws EmptyPageSelectionError for selected pages with empty selection', () {
        const input = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
        );

        expect(
          () => input.parsedSelection,
          throwsA(isA<EmptyPageSelectionError>()),
        );
      });

      test('throws EmptyPageSelectionError for whitespace selection', () {
        const input = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '   ',
        );

        expect(
          () => input.parsedSelection,
          throwsA(isA<EmptyPageSelectionError>()),
        );
      });

      test('parses valid selected pages', () {
        const input = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5, 8, last',
        );

        expect(input.parsedSelection, isNotNull);
      });

      test('throws PageSelectionError for malformed selection', () {
        const input = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: 'invalid',
        );

        expect(() => input.parsedSelection, throwsA(isA<PageSelectionError>()));
      });
    });

    group('copyWith', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: '1-5',
        format: PdfImageFormat.jpeg,
        colorMode: PdfImageColorMode.grayscale,
        dpi: 300,
        quality: 80,
      );

      test('preserves values when no arguments are provided', () {
        expect(input.copyWith(), input);
      });

      test('updates scope', () {
        expect(
          input.copyWith(scope: PdfToImagePageScope.allPages).scope,
          PdfToImagePageScope.allPages,
        );
      });

      test('updates selection', () {
        expect(input.copyWith(selection: '2-6').selection, '2-6');
      });

      test('updates format', () {
        expect(
          input.copyWith(format: PdfImageFormat.webp).format,
          PdfImageFormat.webp,
        );
      });

      test('updates color mode', () {
        expect(
          input.copyWith(colorMode: PdfImageColorMode.color).colorMode,
          PdfImageColorMode.color,
        );
      });

      test('updates DPI', () {
        expect(input.copyWith(dpi: 600).dpi, 600);
      });

      test('updates quality', () {
        expect(input.copyWith(quality: 60).quality, 60);
      });

      test('preserves file path', () {
        expect(input.copyWith(dpi: 600).filePath, input.filePath);
      });
    });

    group('equality', () {
      test('is equal when all values are equal', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
        );

        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-5',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('is not equal when file path differs', () {
        const first = PdfToImageToolInput(filePath: '/documents/one.pdf');
        const second = PdfToImageToolInput(filePath: '/documents/two.pdf');

        expect(first, isNot(second));
      });

      test('is not equal when scope differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.allPages,
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
        );

        expect(first, isNot(second));
      });

      test('is not equal when selection differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          selection: '1-5',
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          selection: '2-6',
        );

        expect(first, isNot(second));
      });

      test('is not equal when format differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          format: PdfImageFormat.png,
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          format: PdfImageFormat.jpeg,
        );

        expect(first, isNot(second));
      });

      test('is not equal when color mode differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          colorMode: PdfImageColorMode.color,
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          colorMode: PdfImageColorMode.grayscale,
        );

        expect(first, isNot(second));
      });

      test('is not equal when DPI differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          dpi: 150,
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          dpi: 300,
        );

        expect(first, isNot(second));
      });

      test('is not equal when quality differs', () {
        const first = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          quality: 80,
        );
        const second = PdfToImageToolInput(
          filePath: '/documents/input.pdf',
          quality: 90,
        );

        expect(first, isNot(second));
      });
    });
  });

  group('PdfToImageMapper', () {
    test('maps input to engine input', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        format: PdfImageFormat.jpeg,
        colorMode: PdfImageColorMode.grayscale,
        dpi: 300,
        quality: 75,
      );

      final result = input.toPdfToImageInput();

      expect(result.file.path, '/documents/input.pdf');
      expect(result.selection, isNull);
      expect(result.format, PdfImageFormat.jpeg);
      expect(result.colorMode, PdfImageColorMode.grayscale);
      expect(result.dpi, 300);
      expect(result.quality, 75);
    });

    test('maps selected pages to parsed selection', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: '1-5, 8',
        format: PdfImageFormat.webp,
        colorMode: PdfImageColorMode.color,
        dpi: 600,
        quality: 80,
      );

      final result = input.toPdfToImageInput();

      expect(result.file.path, '/documents/input.pdf');
      expect(result.selection, isNotNull);
      expect(result.format, PdfImageFormat.webp);
      expect(result.colorMode, PdfImageColorMode.color);
      expect(result.dpi, 600);
      expect(result.quality, 80);
    });

    test('propagates invalid selected page selection', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: 'invalid',
      );

      expect(input.toPdfToImageInput, throwsA(isA<PageSelectionError>()));
    });

    test('propagates empty selected page selection', () {
      const input = PdfToImageToolInput(
        filePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
      );

      expect(input.toPdfToImageInput, throwsA(isA<EmptyPageSelectionError>()));
    });
  });
}
