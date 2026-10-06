import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';

import 'package:velin/features/tools/tools.dart';

void main() {
  group('ImageToPdfState', () {
    test('has the expected defaults', () {
      const state = ImageToPdfState();

      expect(state.inputs, isEmpty);
      expect(state.viewMode, ImagePickerViewMode.list);
      expect(state.pageSize, ImageToPdfPageSize.auto);
      expect(state.orientation, ImageToPdfOrientation.auto);
      expect(state.fit, ImageToPdfFit.contain);
      expect(state.outputFileName, 'images.pdf');
      expect(state.outputDirectory, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('hasImages reflects whether inputs exist', () {
      expect(const ImageToPdfState().hasImages, isFalse);

      expect(
        ImageToPdfState(
          inputs: [const ImageToPdfToolInput(filePath: '/images/photo.png')],
        ).hasImages,
        isTrue,
      );
    });

    group('hasValidOutputDirectory', () {
      test('is false when directory is null', () {
        const state = ImageToPdfState();

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when directory is empty', () {
        const state = ImageToPdfState(outputDirectory: '');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is false when directory contains only whitespace', () {
        const state = ImageToPdfState(outputDirectory: '   ');

        expect(state.hasValidOutputDirectory, isFalse);
      });

      test('is true when directory contains a non-whitespace value', () {
        const state = ImageToPdfState(outputDirectory: '/documents');

        expect(state.hasValidOutputDirectory, isTrue);
      });
    });

    group('hasValidOutputFileName', () {
      test('is true for the default file name', () {
        const state = ImageToPdfState();

        expect(state.hasValidOutputFileName, isTrue);
      });

      test('is false when file name is empty', () {
        const state = ImageToPdfState(outputFileName: '');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('is false when file name contains only whitespace', () {
        const state = ImageToPdfState(outputFileName: '   ');

        expect(state.hasValidOutputFileName, isFalse);
      });

      test('is true when file name contains a non-whitespace value', () {
        const state = ImageToPdfState(outputFileName: 'output.pdf');

        expect(state.hasValidOutputFileName, isTrue);
      });
    });

    group('canConvert', () {
      test('is false when there are no images', () {
        const state = ImageToPdfState(outputDirectory: '/documents');

        expect(state.canConvert, isFalse);
      });

      test('is false when output directory is invalid', () {
        const state = ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        );

        expect(state.canConvert, isFalse);
      });

      test('is false when output file name is invalid', () {
        const state = ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          outputFileName: '   ',
        );

        expect(state.canConvert, isFalse);
      });

      test('is false while submitting', () {
        const state = ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          isSubmitting: true,
        );

        expect(state.canConvert, isFalse);
      });

      test('is true when all conversion requirements are valid', () {
        const state = ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          outputFileName: 'output.pdf',
        );

        expect(state.canConvert, isTrue);
      });
    });

    group('copyWith', () {
      test('preserves values that are not changed', () {
        const state = ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          viewMode: ImagePickerViewMode.grid,
          pageSize: ImageToPdfPageSize.a4,
          orientation: ImageToPdfOrientation.landscape,
          fit: ImageToPdfFit.cover,
          outputFileName: 'output.pdf',
          outputDirectory: '/documents',
          isSubmitting: true,
        );

        final result = state.copyWith();

        expect(result, state);
      });

      test('updates all supplied values', () {
        const state = ImageToPdfState();

        final inputs = [
          const ImageToPdfToolInput(filePath: '/images/photo.png'),
        ];

        final result = state.copyWith(
          inputs: inputs,
          viewMode: ImagePickerViewMode.grid,
          pageSize: ImageToPdfPageSize.a4,
          orientation: ImageToPdfOrientation.landscape,
          fit: ImageToPdfFit.cover,
          outputFileName: 'output.pdf',
          outputDirectory: '/documents',
          isSubmitting: true,
        );

        expect(result.inputs, inputs);
        expect(result.viewMode, ImagePickerViewMode.grid);
        expect(result.pageSize, ImageToPdfPageSize.a4);
        expect(result.orientation, ImageToPdfOrientation.landscape);
        expect(result.fit, ImageToPdfFit.cover);
        expect(result.outputFileName, 'output.pdf');
        expect(result.outputDirectory, '/documents');
        expect(result.isSubmitting, isTrue);
      });

      test('explicitly clears output directory with null', () {
        const state = ImageToPdfState(outputDirectory: '/documents');

        final result = state.copyWith(outputDirectory: null);

        expect(result.outputDirectory, isNull);
      });

      test('preserves output directory when not supplied', () {
        const state = ImageToPdfState(outputDirectory: '/documents');

        final result = state.copyWith();

        expect(result.outputDirectory, '/documents');
      });

      test('updates inputs', () {
        const state = ImageToPdfState();

        final inputs = [
          const ImageToPdfToolInput(filePath: '/images/one.png'),
          const ImageToPdfToolInput(filePath: '/images/two.png'),
        ];

        final result = state.copyWith(inputs: inputs);

        expect(result.inputs, inputs);
      });

      test('updates view mode', () {
        const state = ImageToPdfState();

        final result = state.copyWith(viewMode: ImagePickerViewMode.grid);

        expect(result.viewMode, ImagePickerViewMode.grid);
      });

      test('updates page setup options', () {
        const state = ImageToPdfState();

        final result = state.copyWith(
          pageSize: ImageToPdfPageSize.letter,
          orientation: ImageToPdfOrientation.portrait,
          fit: ImageToPdfFit.stretch,
        );

        expect(result.pageSize, ImageToPdfPageSize.letter);
        expect(result.orientation, ImageToPdfOrientation.portrait);
        expect(result.fit, ImageToPdfFit.stretch);
      });

      test('updates output file name', () {
        const state = ImageToPdfState();

        final result = state.copyWith(outputFileName: 'converted.pdf');

        expect(result.outputFileName, 'converted.pdf');
      });

      test('updates submitting state', () {
        const state = ImageToPdfState();

        final result = state.copyWith(isSubmitting: true);

        expect(result.isSubmitting, isTrue);
      });
    });

    test('supports equality for equivalent states', () {
      const first = ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        viewMode: ImagePickerViewMode.grid,
        pageSize: ImageToPdfPageSize.a4,
        orientation: ImageToPdfOrientation.landscape,
        fit: ImageToPdfFit.cover,
        outputFileName: 'output.pdf',
        outputDirectory: '/documents',
        isSubmitting: true,
      );

      const second = ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        viewMode: ImagePickerViewMode.grid,
        pageSize: ImageToPdfPageSize.a4,
        orientation: ImageToPdfOrientation.landscape,
        fit: ImageToPdfFit.cover,
        outputFileName: 'output.pdf',
        outputDirectory: '/documents',
        isSubmitting: true,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('states with different values are not equal', () {
      const first = ImageToPdfState(outputDirectory: '/documents');

      const second = ImageToPdfState(outputDirectory: '/other');

      expect(first, isNot(second));
    });
  });
}
