import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';

void main() {
  const filePath = '/input/source.pdf';
  const outputPath = '/output/result.pdf';

  group('WatermarkPageScope', () {
    test('only selectedPages requires a selection', () {
      expect(WatermarkPageScope.allPages.requiresSelection, isFalse);
      expect(WatermarkPageScope.selectedPages.requiresSelection, isTrue);
    });
  });

  group('AddWatermarkToolInput', () {
    test('has expected defaults', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
      );

      expect(input.type, WatermarkType.text);
      expect(input.text, 'CONFIDENTIAL');
      expect(input.imageFilePath, isNull);
      expect(input.fontName, isNull);
      expect(input.fontSize, 48);
      expect(input.colorHex, '#808080');
      expect(input.opacity, 0.3);
      expect(input.rotation, -45);
      expect(input.position, WatermarkPosition.center);
      expect(input.xOffset, 0);
      expect(input.yOffset, 0);
      expect(input.imageWidthPercent, 30);
      expect(input.layer, WatermarkLayer.foreground);
      expect(input.scope, WatermarkPageScope.allPages);
      expect(input.selection, '');
    });

    test('detects text watermark content', () {
      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          type: WatermarkType.text,
          text: 'Draft',
        ).hasWatermarkContent,
        isTrue,
      );

      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          type: WatermarkType.text,
          text: '   ',
        ).hasWatermarkContent,
        isFalse,
      );
    });

    test('detects image watermark content', () {
      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          type: WatermarkType.image,
          imageFilePath: '/images/logo.png',
        ).hasWatermarkContent,
        isTrue,
      );

      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          type: WatermarkType.image,
          imageFilePath: '   ',
        ).hasWatermarkContent,
        isFalse,
      );
    });

    test('validates hexadecimal colors', () {
      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          colorHex: '#FF0000',
        ).hasValidColor,
        isTrue,
      );

      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          colorHex: 'FF0000',
        ).hasValidColor,
        isTrue,
      );

      expect(
        const AddWatermarkToolInput(
          filePath: filePath,
          outputFilePath: outputPath,
          colorHex: '#GG0000',
        ).hasValidColor,
        isFalse,
      );
    });

    test('returns null parsed selection for all pages', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        scope: WatermarkPageScope.allPages,
        selection: '',
      );

      expect(input.parsedSelection, isNull);
    });

    test('parses selected pages', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        scope: WatermarkPageScope.selectedPages,
        selection: '1-3, 5',
      );

      final selection = input.parsedSelection;

      expect(selection, isNotNull);
      expect(selection!.items, hasLength(2));
    });

    test('throws when selected pages have empty selection', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        scope: WatermarkPageScope.selectedPages,
        selection: '   ',
      );

      expect(
        () => input.parsedSelection,
        throwsA(isA<EmptyPageSelectionError>()),
      );
    });

    test('throws when selected pages have malformed selection', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        scope: WatermarkPageScope.selectedPages,
        selection: 'invalid',
      );

      expect(() => input.parsedSelection, throwsA(isA<PageSelectionError>()));
    });

    test('copyWith preserves unspecified values', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        text: 'Draft',
        imageFilePath: '/images/logo.png',
        fontName: 'Helvetica',
        fontSize: 36,
        colorHex: '#FF0000',
        opacity: 0.8,
        rotation: 30,
        position: WatermarkPosition.bottomRight,
        xOffset: 10,
        yOffset: 20,
        imageWidthPercent: 60,
        layer: WatermarkLayer.background,
        scope: WatermarkPageScope.selectedPages,
        selection: '1-5',
      );

      final copy = input.copyWith(text: 'Changed');

      expect(copy.filePath, input.filePath);
      expect(copy.outputFilePath, input.outputFilePath);
      expect(copy.text, 'Changed');
      expect(copy.imageFilePath, input.imageFilePath);
      expect(copy.fontName, input.fontName);
      expect(copy.fontSize, input.fontSize);
      expect(copy.colorHex, input.colorHex);
      expect(copy.opacity, input.opacity);
      expect(copy.rotation, input.rotation);
      expect(copy.position, input.position);
      expect(copy.xOffset, input.xOffset);
      expect(copy.yOffset, input.yOffset);
      expect(copy.imageWidthPercent, input.imageWidthPercent);
      expect(copy.layer, input.layer);
      expect(copy.scope, input.scope);
      expect(copy.selection, input.selection);
    });

    test('copyWith can explicitly clear nullable values', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        imageFilePath: '/images/logo.png',
        fontName: 'Helvetica',
      );

      final copy = input.copyWith(imageFilePath: null, fontName: null);

      expect(copy.imageFilePath, isNull);
      expect(copy.fontName, isNull);
    });

    test('maps to engine input', () {
      const input = AddWatermarkToolInput(
        filePath: filePath,
        outputFilePath: outputPath,
        type: WatermarkType.text,
        text: 'Confidential',
        fontName: 'Helvetica',
        fontSize: 36,
        colorHex: '#ff0000',
        opacity: 0.75,
        rotation: 45,
        position: WatermarkPosition.bottomRight,
        xOffset: 10,
        yOffset: 20,
        imageWidthPercent: 60,
        layer: WatermarkLayer.background,
        scope: WatermarkPageScope.selectedPages,
        selection: '1-3',
      );

      final mapped = input.toAddWatermarkInput();

      expect(mapped.file.path, filePath);
      expect(mapped.outputFile.path, outputPath);
      expect(mapped.type, WatermarkType.text);
      expect(mapped.text, 'Confidential');
      expect(mapped.fontName, 'Helvetica');
      expect(mapped.fontSize, 36);
      expect(mapped.colorHex, 'FF0000');
      expect(mapped.opacity, 0.75);
      expect(mapped.rotation, 45);
      expect(mapped.position, WatermarkPosition.bottomRight);
      expect(mapped.xOffset, 10);
      expect(mapped.yOffset, 20);
      expect(mapped.imageWidthPercent, 60);
      expect(mapped.layer, WatermarkLayer.background);
    });
  });

  group('normalizeHexColor', () {
    test('removes hash and normalizes case', () {
      expect(normalizeHexColor('#ff00aa'), 'FF00AA');
    });

    test('handles bare hexadecimal color', () {
      expect(normalizeHexColor('ff00aa'), 'FF00AA');
    });

    test('trims surrounding whitespace', () {
      expect(normalizeHexColor('  #ff00aa  '), 'FF00AA');
    });
  });
}
