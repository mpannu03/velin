import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockPdfToImageEngine extends Mock implements PdfToImageEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockPdfToImageEngine pdfToImageEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController appEffectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(PdfToImageToolInput(filePath: 'input.pdf'));
    registerFallbackValue(PdfToImageInput(file: File('input.pdf')));
    registerFallbackValue(File('input.pdf'));
    registerFallbackValue(Directory('input.pdf_images/'));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    pdfToImageEngine = MockPdfToImageEngine();
    taskManager = MockTaskManager();
    appEffectController = MockAppEffectController();
  });

  PdfToImageCubit buildCubit() {
    return PdfToImageCubit(
      l10n: l10n,
      filePicker: filePicker,
      pdfToImageEngine: pdfToImageEngine,
      taskManager: taskManager,
      appEffectController: appEffectController,
    );
  }

  group('pickFile', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'sets input file and generated output directory on success',
      setUp: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/report.pdf'));
      },
      build: buildCubit,
      act: (cubit) => cubit.pickFile(),
      verify: (_) {
        verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when picker is cancelled',
      setUp: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async => const Failure(DocumentFilePickerError('cancelled')),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.pickFile(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'notifies an error for an unexpected picker failure',
      setUp: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => Failure(Exception('picker failed')));
      },
      build: buildCubit,
      act: (cubit) => cubit.pickFile(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('changeScope', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'changes scope',
      build: buildCubit,
      act: (cubit) {
        cubit.changeScope(PdfToImagePageScope.selectedPages);
      },
      expect: () => [
        const PdfToImageState(scope: PdfToImagePageScope.selectedPages),
      ],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when scope is unchanged',
      build: buildCubit,
      act: (cubit) {
        cubit.changeScope(PdfToImagePageScope.allPages);
      },
      expect: () => <PdfToImageState>[],
    );
  });

  group('updateSelection', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'updates selection',
      build: buildCubit,
      act: (cubit) => cubit.updateSelection('1-5, last'),
      expect: () => [const PdfToImageState(selection: '1-5, last')],
    );
  });

  group('changeFormat', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'changes format',
      build: buildCubit,
      act: (cubit) => cubit.changeFormat(PdfImageFormat.jpeg),
      expect: () => [const PdfToImageState(format: PdfImageFormat.jpeg)],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when format is unchanged',
      build: buildCubit,
      act: (cubit) => cubit.changeFormat(PdfImageFormat.png),
      expect: () => <PdfToImageState>[],
    );
  });

  group('changeColorMode', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'changes color mode',
      build: buildCubit,
      act: (cubit) {
        cubit.changeColorMode(PdfImageColorMode.grayscale);
      },
      expect: () => [
        const PdfToImageState(colorMode: PdfImageColorMode.grayscale),
      ],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when color mode is unchanged',
      build: buildCubit,
      act: (cubit) {
        cubit.changeColorMode(PdfImageColorMode.color);
      },
      expect: () => <PdfToImageState>[],
    );
  });

  group('changeDpi', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'changes DPI',
      build: buildCubit,
      act: (cubit) => cubit.changeDpi(300),
      expect: () => [const PdfToImageState(dpi: 300)],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when DPI is unchanged',
      build: buildCubit,
      act: (cubit) => cubit.changeDpi(150),
      expect: () => <PdfToImageState>[],
    );
  });

  group('changeQuality', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'changes quality',
      build: buildCubit,
      act: (cubit) => cubit.changeQuality(75),
      expect: () => [const PdfToImageState(quality: 75)],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'clamps quality below minimum to 1',
      build: buildCubit,
      act: (cubit) => cubit.changeQuality(-10),
      expect: () => [const PdfToImageState(quality: 1)],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'clamps quality above maximum to 100',
      build: buildCubit,
      act: (cubit) => cubit.changeQuality(150),
      expect: () => [const PdfToImageState(quality: 100)],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when clamped quality equals current quality',
      build: buildCubit,
      act: (cubit) => cubit.changeQuality(90),
      expect: () => <PdfToImageState>[],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'sets output directory on success',
      setUp: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));
      },
      build: buildCubit,
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        const PdfToImageState(outputDirectory: '/documents/output'),
      ],
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does not emit when picker is cancelled',
      setUp: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => const Failure(DocumentFilePickerError('cancelled')),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'notifies an error for an unexpected picker failure',
      setUp: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => Failure(Exception('picker failed')));
      },
      build: buildCubit,
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('convert', () {
    blocTest<PdfToImageCubit, PdfToImageState>(
      'warns when input file is missing',
      build: buildCubit,
      act: (cubit) => cubit.convert(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageWarningNoFile,
            type: NotificationType.warning,
          ),
        ).called(1);

        verifyNever(
          () => pdfToImageEngine.convert(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        );
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'warns when output directory is missing',
      build: buildCubit,
      seed: () => const PdfToImageState(inputFilePath: '/documents/input.pdf'),
      act: (cubit) => cubit.convert(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'warns when selected-pages scope has no selection',
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageWarningNoSelection,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'warns when selected page selection is invalid',
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: 'invalid',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageSelectionInvalid,
            type: NotificationType.warning,
          ),
        ).called(1);

        verifyNever(
          () => pdfToImageEngine.convert(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        );
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'converts successfully and reports the number of generated files',
      setUp: () {
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

        when(
          () => pdfToImageEngine.convert(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenAnswer(
          (_) async => [
            File('/documents/output/page-1.png'),
            File('/documents/output/page-2.png'),
            File('/documents/output/page-3.png'),
          ],
        );
      },
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: '1-3',
        format: PdfImageFormat.jpeg,
        colorMode: PdfImageColorMode.grayscale,
        dpi: 300,
        quality: 80,
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-3',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          scope: PdfToImagePageScope.selectedPages,
          selection: '1-3',
          format: PdfImageFormat.jpeg,
          colorMode: PdfImageColorMode.grayscale,
          dpi: 300,
          quality: 80,
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        // Single verify: capture both named arguments in one call.
        final captured = verify(
          () => pdfToImageEngine.convert(
            input: captureAny(named: 'input'),
            outputDirectory: captureAny(named: 'outputDirectory'),
          ),
        ).captured;

        final input = captured[0] as PdfToImageInput;
        final outputDirectory = captured[1] as Directory;

        expect(input.file.path, '/documents/input.pdf');
        expect(input.format, PdfImageFormat.jpeg);
        expect(input.colorMode, PdfImageColorMode.grayscale);
        expect(input.dpi, 300);
        expect(input.quality, 80);
        expect(input.selection, isNotNull);

        expect(outputDirectory.path, '/documents/output');

        verify(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: l10n.toolsPdfToImageButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageSuccess(3),
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'reports an error when the engine fails',
      setUp: () {
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

        when(
          () => pdfToImageEngine.convert(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenThrow(Exception('conversion failed'));
      },
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'reports an error when task submission fails',
      setUp: () {
        when(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        ).thenThrow(Exception('task failed'));
      },
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.convert(),
      expect: () => [
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const PdfToImageState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: l10n.toolsPdfToImageButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsPdfToImageFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<PdfToImageCubit, PdfToImageState>(
      'does nothing when already submitting',
      build: buildCubit,
      seed: () => const PdfToImageState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        isSubmitting: true,
      ),
      act: (cubit) => cubit.convert(),
      expect: () => <PdfToImageState>[],
      verify: (_) {
        verifyNever(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        );

        verifyNever(
          () => pdfToImageEngine.convert(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        );
      },
    );
  });
}
