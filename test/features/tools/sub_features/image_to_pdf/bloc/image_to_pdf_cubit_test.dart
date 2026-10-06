import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockImageToPdfEngine extends Mock implements ImageToPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockImageToPdfEngine imageToPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController appEffectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(ImageToPdfInput(images: []));
    registerFallbackValue(File('/documents/converted.pdf'));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    imageToPdfEngine = MockImageToPdfEngine();
    taskManager = MockTaskManager();
    appEffectController = MockAppEffectController();
  });

  ImageToPdfCubit buildCubit() {
    return ImageToPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      imageToPdfEngine: imageToPdfEngine,
      taskManager: taskManager,
      appEffectController: appEffectController,
    );
  }

  void stubSuccessfulTaskSubmission() {
    when(
      () => taskManager.submit(
        id: any(named: 'id'),
        title: any(named: 'title'),
        operation: any(named: 'operation'),
      ),
    ).thenAnswer((invocation) async {
      final operation =
          invocation.namedArguments[#operation] as Future<void> Function();

      await operation();
    });
  }

  group('pickImages', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'adds picked images and uses their directory as the output directory',
      build: () {
        when(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).thenAnswer(
          (_) async =>
              const Success(['/images/first.png', '/images/second.jpg']),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickImages(),
      expect: () => [
        ImageToPdfState(
          inputs: const [
            ImageToPdfToolInput(filePath: '/images/first.png'),
            ImageToPdfToolInput(filePath: '/images/second.jpg'),
          ],
          outputDirectory: directoryWithTrailingSeparator('/images/first.png'),
        ),
      ],
      verify: (_) {
        verify(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).called(1);
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'appends picked images to existing images',
      build: () {
        when(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).thenAnswer((_) async => const Success(['/images/second.png']));

        return buildCubit();
      },
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/first.png')],
        outputDirectory: '/documents/',
      ),
      act: (cubit) => cubit.pickImages(),
      expect: () => [
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/first.png'),
            ImageToPdfToolInput(filePath: '/images/second.png'),
          ],
          outputDirectory: '/documents/',
        ),
      ],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when picker returns an empty list',
      build: () {
        when(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).thenAnswer((_) async => const Success([]));

        return buildCubit();
      },
      act: (cubit) => cubit.pickImages(),
      expect: () => <ImageToPdfState>[],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when picker is cancelled',
      build: () {
        when(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickImages(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'notifies an error for an unexpected picker failure',
      build: () {
        when(
          () => filePicker.pickFiles(
            allowedExtensions: ImageToPdfCubit.supportedExtensions,
          ),
        ).thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickImages(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('removeImage', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'removes the image at the requested index',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [
          ImageToPdfToolInput(filePath: '/images/first.png'),
          ImageToPdfToolInput(filePath: '/images/second.png'),
          ImageToPdfToolInput(filePath: '/images/third.png'),
        ],
      ),
      act: (cubit) => cubit.removeImage(1),
      expect: () => [
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/first.png'),
            ImageToPdfToolInput(filePath: '/images/third.png'),
          ],
        ),
      ],
    );
  });

  group('reorderImages', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'moves an image to the requested position',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [
          ImageToPdfToolInput(filePath: '/images/first.png'),
          ImageToPdfToolInput(filePath: '/images/second.png'),
          ImageToPdfToolInput(filePath: '/images/third.png'),
        ],
      ),
      act: (cubit) => cubit.reorderImages(0, 2),
      expect: () => [
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/second.png'),
            ImageToPdfToolInput(filePath: '/images/third.png'),
            ImageToPdfToolInput(filePath: '/images/first.png'),
          ],
        ),
      ],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'clamps a target past the end of the list',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [
          ImageToPdfToolInput(filePath: '/images/first.png'),
          ImageToPdfToolInput(filePath: '/images/second.png'),
          ImageToPdfToolInput(filePath: '/images/third.png'),
        ],
      ),
      act: (cubit) => cubit.reorderImages(0, 99),
      expect: () => [
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/second.png'),
            ImageToPdfToolInput(filePath: '/images/third.png'),
            ImageToPdfToolInput(filePath: '/images/first.png'),
          ],
        ),
      ],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when old and new indexes are equal',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [
          ImageToPdfToolInput(filePath: '/images/first.png'),
          ImageToPdfToolInput(filePath: '/images/second.png'),
        ],
      ),
      act: (cubit) => cubit.reorderImages(1, 1),
      expect: () => <ImageToPdfState>[],
    );
  });

  group('changeViewMode', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'changes the view mode',
      build: buildCubit,
      act: (cubit) => cubit.changeViewMode(ImagePickerViewMode.grid),
      expect: () => [const ImageToPdfState(viewMode: ImagePickerViewMode.grid)],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when the view mode is unchanged',
      build: buildCubit,
      seed: () => const ImageToPdfState(viewMode: ImagePickerViewMode.grid),
      act: (cubit) => cubit.changeViewMode(ImagePickerViewMode.grid),
      expect: () => <ImageToPdfState>[],
    );
  });

  group('changePageSize', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'changes the page size',
      build: buildCubit,
      act: (cubit) => cubit.changePageSize(ImageToPdfPageSize.a4),
      expect: () => [const ImageToPdfState(pageSize: ImageToPdfPageSize.a4)],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when the page size is unchanged',
      build: buildCubit,
      seed: () => const ImageToPdfState(pageSize: ImageToPdfPageSize.a4),
      act: (cubit) => cubit.changePageSize(ImageToPdfPageSize.a4),
      expect: () => <ImageToPdfState>[],
    );
  });

  group('changeOrientation', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'changes the orientation',
      build: buildCubit,
      act: (cubit) => cubit.changeOrientation(ImageToPdfOrientation.landscape),
      expect: () => [
        const ImageToPdfState(orientation: ImageToPdfOrientation.landscape),
      ],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when the orientation is unchanged',
      build: buildCubit,
      seed: () =>
          const ImageToPdfState(orientation: ImageToPdfOrientation.landscape),
      act: (cubit) => cubit.changeOrientation(ImageToPdfOrientation.landscape),
      expect: () => <ImageToPdfState>[],
    );
  });

  group('changeFit', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'changes the fit mode',
      build: buildCubit,
      act: (cubit) => cubit.changeFit(ImageToPdfFit.cover),
      expect: () => [const ImageToPdfState(fit: ImageToPdfFit.cover)],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when the fit mode is unchanged',
      build: buildCubit,
      seed: () => const ImageToPdfState(fit: ImageToPdfFit.cover),
      act: (cubit) => cubit.changeFit(ImageToPdfFit.cover),
      expect: () => <ImageToPdfState>[],
    );
  });

  group('updateOutputFileName', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'normalizes the PDF file name',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('  converted  '),
      expect: () => [const ImageToPdfState(outputFileName: 'converted.pdf')],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'updates the output directory',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [const ImageToPdfState(outputDirectory: '/documents')],
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when directory picker is cancelled',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'notifies an error for an unexpected directory picker failure',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(Exception('directory picker failed')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('convert', () {
    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'warns when no images are selected',
      build: buildCubit,
      seed: () => const ImageToPdfState(outputDirectory: '/documents'),
      act: (cubit) => cubit.convert(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfWarningNoImages,
            type: NotificationType.warning,
          ),
        ).called(1);

        verifyNever(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        );
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'warns when output directory is missing',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'warns when output file name is invalid',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        outputDirectory: '/documents',
        outputFileName: '   ',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'converts images and notifies success',
      build: () {
        stubSuccessfulTaskSubmission();

        when(
          () => imageToPdfEngine.convert(
            input: any(named: 'input'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenAnswer((_) async {
          return File('/documents/converted.pdf');
        });

        return buildCubit();
      },
      seed: () => const ImageToPdfState(
        inputs: [
          ImageToPdfToolInput(filePath: '/images/first.png'),
          ImageToPdfToolInput(filePath: '/images/second.jpg'),
        ],
        pageSize: ImageToPdfPageSize.a4,
        orientation: ImageToPdfOrientation.landscape,
        fit: ImageToPdfFit.cover,
        outputDirectory: '/documents',
        outputFileName: 'converted.pdf',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/first.png'),
            ImageToPdfToolInput(filePath: '/images/second.jpg'),
          ],
          pageSize: ImageToPdfPageSize.a4,
          orientation: ImageToPdfOrientation.landscape,
          fit: ImageToPdfFit.cover,
          outputDirectory: '/documents',
          outputFileName: 'converted.pdf',
          isSubmitting: true,
        ),
        const ImageToPdfState(
          inputs: [
            ImageToPdfToolInput(filePath: '/images/first.png'),
            ImageToPdfToolInput(filePath: '/images/second.jpg'),
          ],
          pageSize: ImageToPdfPageSize.a4,
          orientation: ImageToPdfOrientation.landscape,
          fit: ImageToPdfFit.cover,
          outputDirectory: '/documents',
          outputFileName: 'converted.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => imageToPdfEngine.convert(
            input: captureAny(named: 'input'),
            outputFile: captureAny(named: 'outputFile'),
          ),
        ).captured;

        final input = captured[0] as ImageToPdfInput;
        final outputFile = captured[1] as File;

        expect(input.images[0].path, '/images/first.png');
        expect(input.images[1].path, '/images/second.jpg');
        expect(input.pageSize, ImageToPdfPageSize.a4);
        expect(input.orientation, ImageToPdfOrientation.landscape);
        expect(input.fit, ImageToPdfFit.cover);
        expect(input.margin, 10);
        expect(input.dpi, 150);

        expect(
          outputFile.path,
          '${'/documents'}${Platform.pathSeparator}converted.pdf',
        );

        verify(
          () => taskManager.submit(
            id: any(named: 'id', that: startsWith('image-to-pdf-')),
            title: l10n.toolsImageToPdfButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfSuccess(2),
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'notifies failure when the engine fails',
      build: () {
        stubSuccessfulTaskSubmission();

        when(
          () => imageToPdfEngine.convert(
            input: any(named: 'input'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenThrow(Exception('conversion failed'));

        return buildCubit();
      },
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        outputDirectory: '/documents',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          isSubmitting: true,
        ),
        const ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfFailed,
            type: NotificationType.error,
          ),
        ).called(1);

        verifyNever(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfSuccess(1),
            type: NotificationType.success,
          ),
        );
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'notifies failure when task submission fails',
      build: () {
        when(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        ).thenThrow(Exception('task failed'));

        return buildCubit();
      },
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        outputDirectory: '/documents',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          isSubmitting: true,
        ),
        const ImageToPdfState(
          inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
          outputDirectory: '/documents',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsImageToPdfFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<ImageToPdfCubit, ImageToPdfState>(
      'does nothing when conversion is already submitting',
      build: buildCubit,
      seed: () => const ImageToPdfState(
        inputs: [ImageToPdfToolInput(filePath: '/images/photo.png')],
        outputDirectory: '/documents',
        isSubmitting: true,
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <ImageToPdfState>[],
      verify: (_) {
        verifyNever(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        );
      },
    );
  });
}
