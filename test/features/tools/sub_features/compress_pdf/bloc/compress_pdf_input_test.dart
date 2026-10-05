import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';

void main() {
  group('CompressPdfToolInput', () {
    test('uses default quality', () {
      const input = CompressPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/compressed.pdf',
      );

      expect(input.filePath, '/documents/input.pdf');
      expect(input.outputFilePath, '/documents/compressed.pdf');
      expect(input.quality, 75);
    });

    test('accepts custom quality', () {
      const input = CompressPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/compressed.pdf',
        quality: 40,
      );

      expect(input.quality, 40);
    });

    group('copyWith', () {
      const input = CompressPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/compressed.pdf',
        quality: 60,
      );

      test('preserves values when omitted', () {
        expect(input.copyWith(), input);
      });

      test('updates supplied values', () {
        final result = input.copyWith(
          filePath: '/documents/other.pdf',
          outputFilePath: '/output/result.pdf',
          quality: 90,
        );

        expect(result.filePath, '/documents/other.pdf');
        expect(result.outputFilePath, '/output/result.pdf');
        expect(result.quality, 90);
      });

      test('preserves individual values when not supplied', () {
        final result = input.copyWith(quality: 80);

        expect(result.filePath, input.filePath);
        expect(result.outputFilePath, input.outputFilePath);
        expect(result.quality, 80);
      });
    });

    group('toCompressPdfInput', () {
      test('maps file path and quality', () {
        const input = CompressPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/compressed.pdf',
          quality: 60,
        );

        final result = input.toCompressPdfInput();

        expect(result.file.path, '/documents/input.pdf');
        expect(result.compressionLevel, 60);
      });

      test('clamps quality below minimum', () {
        const input = CompressPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/compressed.pdf',
          quality: -10,
        );

        final result = input.toCompressPdfInput();

        expect(result.compressionLevel, CompressPdfToolInput.minQuality);
      });

      test('clamps quality above maximum', () {
        const input = CompressPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/compressed.pdf',
          quality: 150,
        );

        final result = input.toCompressPdfInput();

        expect(result.compressionLevel, CompressPdfToolInput.maxQuality);
      });

      test('preserves quality at the boundaries', () {
        const minimum = CompressPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/compressed.pdf',
          quality: CompressPdfToolInput.minQuality,
        );

        const maximum = CompressPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/compressed.pdf',
          quality: CompressPdfToolInput.maxQuality,
        );

        expect(
          minimum.toCompressPdfInput().compressionLevel,
          CompressPdfToolInput.minQuality,
        );
        expect(
          maximum.toCompressPdfInput().compressionLevel,
          CompressPdfToolInput.maxQuality,
        );
      });
    });
  });
}
