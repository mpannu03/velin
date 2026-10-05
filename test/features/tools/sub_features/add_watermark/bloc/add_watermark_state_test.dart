import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';

void main() {
  group('AddWatermarkState', () {
    test('has expected defaults', () {
      const state = AddWatermarkState();

      expect(state.inputFilePath, isNull);
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.type, WatermarkType.text);
      expect(state.text, 'CONFIDENTIAL');
      expect(state.imageFilePath, isNull);
      expect(state.fontName, isNull);
      expect(state.fontSize, 48);
      expect(state.colorHex, '#808080');
      expect(state.opacity, 0.3);
      expect(state.rotation, -45);
      expect(state.position, WatermarkPosition.center);
      expect(state.xOffset, 0);
      expect(state.yOffset, 0);
      expect(state.imageWidthPercent, 30);
      expect(state.layer, WatermarkLayer.foreground);
      expect(state.scope, WatermarkPageScope.allPages);
      expect(state.selection, '');
      expect(state.isSubmitting, isFalse);
    });

    test('validates input file', () {
      expect(
        const AddWatermarkState(inputFilePath: null).hasInputFile,
        isFalse,
      );
      expect(const AddWatermarkState(inputFilePath: '').hasInputFile, isFalse);
      expect(
        const AddWatermarkState(inputFilePath: '   ').hasInputFile,
        isFalse,
      );
      expect(
        const AddWatermarkState(inputFilePath: '/input/file.pdf').hasInputFile,
        isTrue,
      );
    });

    test('validates output directory and file name', () {
      expect(const AddWatermarkState().hasValidOutputDirectory, isFalse);
      expect(
        const AddWatermarkState(outputDirectory: '   ').hasValidOutputDirectory,
        isFalse,
      );
      expect(
        const AddWatermarkState(outputDirectory: '/output')
            .hasValidOutputDirectory,
        isTrue,
      );

      expect(const AddWatermarkState().hasValidOutputFileName, isFalse);
      expect(
        const AddWatermarkState(outputFileName: '   ').hasValidOutputFileName,
        isFalse,
      );
      expect(
        const AddWatermarkState(outputFileName: 'result.pdf')
            .hasValidOutputFileName,
        isTrue,
      );
    });

    test('validates selection according to scope', () {
      const allPages = AddWatermarkState(scope: WatermarkPageScope.allPages);

      expect(allPages.hasValidSelection, isFalse);
      expect(allPages.hasValidScopeConfig, isTrue);

      const selectedPagesWithoutSelection = AddWatermarkState(
        scope: WatermarkPageScope.selectedPages,
      );

      expect(selectedPagesWithoutSelection.hasValidSelection, isFalse);
      expect(selectedPagesWithoutSelection.hasValidScopeConfig, isFalse);

      const selectedPagesWithSelection = AddWatermarkState(
        scope: WatermarkPageScope.selectedPages,
        selection: '1-5',
      );

      expect(selectedPagesWithSelection.hasValidSelection, isTrue);
      expect(selectedPagesWithSelection.hasValidScopeConfig, isTrue);
    });

    test('validates text watermark content', () {
      expect(
        const AddWatermarkState(
          type: WatermarkType.text,
          text: 'CONFIDENTIAL',
        ).hasWatermarkContent,
        isTrue,
      );

      expect(
        const AddWatermarkState(
          type: WatermarkType.text,
          text: '',
        ).hasWatermarkContent,
        isFalse,
      );

      expect(
        const AddWatermarkState(
          type: WatermarkType.text,
          text: '   ',
        ).hasWatermarkContent,
        isFalse,
      );
    });

    test('validates image watermark content', () {
      expect(
        const AddWatermarkState(
          type: WatermarkType.image,
          imageFilePath: null,
        ).hasWatermarkContent,
        isFalse,
      );

      expect(
        const AddWatermarkState(
          type: WatermarkType.image,
          imageFilePath: '   ',
        ).hasWatermarkContent,
        isFalse,
      );

      expect(
        const AddWatermarkState(
          type: WatermarkType.image,
          imageFilePath: '/images/logo.png',
        ).hasWatermarkContent,
        isTrue,
      );
    });

    test('validates color', () {
      expect(
        const AddWatermarkState(colorHex: '#FF0000').hasValidColor,
        isTrue,
      );
      expect(const AddWatermarkState(colorHex: 'FF0000').hasValidColor, isTrue);
      expect(
        const AddWatermarkState(colorHex: '#GG0000').hasValidColor,
        isFalse,
      );
      expect(const AddWatermarkState(colorHex: '#FFF').hasValidColor, isFalse);
      expect(
        const AddWatermarkState(colorHex: '#FF00000').hasValidColor,
        isFalse,
      );
    });

    test('can apply watermark when all required values are valid', () {
      const state = AddWatermarkState(
        inputFilePath: '/input/source.pdf',
        outputDirectory: '/output',
        outputFileName: 'watermarked.pdf',
        text: 'CONFIDENTIAL',
        colorHex: '#808080',
      );

      expect(state.canApplyWatermark, isTrue);
    });

    test('cannot apply watermark while submitting', () {
      const state = AddWatermarkState(
        inputFilePath: '/input/source.pdf',
        outputDirectory: '/output',
        outputFileName: 'watermarked.pdf',
        isSubmitting: true,
      );

      expect(state.canApplyWatermark, isFalse);
    });

    test('cannot apply watermark when a required value is invalid', () {
      const base = AddWatermarkState(
        inputFilePath: '/input/source.pdf',
        outputDirectory: '/output',
        outputFileName: 'watermarked.pdf',
      );

      expect(base.canApplyWatermark, isTrue);

      expect(base.copyWith(inputFilePath: null).canApplyWatermark, isFalse);
      expect(base.copyWith(text: '').canApplyWatermark, isFalse);
      expect(base.copyWith(colorHex: '#GGGGGG').canApplyWatermark, isFalse);
      expect(base.copyWith(outputDirectory: null).canApplyWatermark, isFalse);
      expect(base.copyWith(outputFileName: null).canApplyWatermark, isFalse);
      expect(
        base
            .copyWith(scope: WatermarkPageScope.selectedPages, selection: '')
            .canApplyWatermark,
        isFalse,
      );
    });

    test('builds tool input with trimmed paths', () {
      const state = AddWatermarkState(
        inputFilePath: '  /input/source.pdf  ',
        outputDirectory: '  /output/  ',
        outputFileName: '  result.pdf  ',
        text: 'CONFIDENTIAL',
        colorHex: '#ff0000',
      );

      final input = state.toolInput;

      expect(input.filePath, '/input/source.pdf');
      expect(
        input.outputFilePath,
        '/output${Platform.pathSeparator}result.pdf',
      );
      expect(input.type, WatermarkType.text);
      expect(input.text, 'CONFIDENTIAL');
      expect(input.colorHex, '#ff0000');
    });

    test('copyWith preserves unspecified values', () {
      const state = AddWatermarkState(
        inputFilePath: '/input/source.pdf',
        outputDirectory: '/output',
        outputFileName: 'result.pdf',
        text: 'Draft',
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
        isSubmitting: true,
      );

      final copy = state.copyWith(text: 'Changed');

      expect(copy.inputFilePath, state.inputFilePath);
      expect(copy.outputDirectory, state.outputDirectory);
      expect(copy.outputFileName, state.outputFileName);
      expect(copy.type, state.type);
      expect(copy.text, 'Changed');
      expect(copy.fontName, state.fontName);
      expect(copy.fontSize, state.fontSize);
      expect(copy.colorHex, state.colorHex);
      expect(copy.opacity, state.opacity);
      expect(copy.rotation, state.rotation);
      expect(copy.position, state.position);
      expect(copy.xOffset, state.xOffset);
      expect(copy.yOffset, state.yOffset);
      expect(copy.imageWidthPercent, state.imageWidthPercent);
      expect(copy.layer, state.layer);
      expect(copy.scope, state.scope);
      expect(copy.selection, state.selection);
      expect(copy.isSubmitting, state.isSubmitting);
    });

    test('copyWith can explicitly clear nullable values', () {
      const state = AddWatermarkState(
        inputFilePath: '/input/source.pdf',
        outputDirectory: '/output',
        outputFileName: 'result.pdf',
        imageFilePath: '/images/logo.png',
        fontName: 'Helvetica',
      );

      final copy = state.copyWith(
        inputFilePath: null,
        outputDirectory: null,
        outputFileName: null,
        imageFilePath: null,
        fontName: null,
      );

      expect(copy.inputFilePath, isNull);
      expect(copy.outputDirectory, isNull);
      expect(copy.outputFileName, isNull);
      expect(copy.imageFilePath, isNull);
      expect(copy.fontName, isNull);
    });
  });
}
