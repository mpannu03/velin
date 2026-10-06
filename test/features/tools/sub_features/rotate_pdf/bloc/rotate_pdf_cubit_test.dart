import 'dart:io';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockRotatePdfEngine extends Mock implements RotatePdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockRotatePdfEngine rotatePdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(File('input.pdf'));
    registerFallbackValue(
      RotatePdfToolInput(
        filePath: '',
        direction: RotatePdfDirection.clockwise90,
      ),
    );
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    rotatePdfEngine = MockRotatePdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();
  });

  RotatePdfCubit createCubit() {
    return RotatePdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      rotatePdfEngine: rotatePdfEngine,
      taskManager: taskManager,
      appEffectController: effectController,
    );
  }

  void stubTaskManagerToRunOperation() {
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

  group('pickFile', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'sets input and default output values on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/sample.pdf'));

        return createCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/documents/',
          outputFileName: 'sample_rotated.pdf',
        ),
      ],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'preserves an existing output directory',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/sample.pdf'));

        return createCubit();
      },
      seed: () => const RotatePdfState(
        outputDirectory: '/custom/output',
        outputFileName: 'existing.pdf',
      ),
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/custom/output',
          outputFileName: 'sample_rotated.pdf',
        ),
      ],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does not change state for picker cancellation',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

        return createCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <RotatePdfState>[],
      verify: (_) {
        verifyNever(
          () => effectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'notifies an error for an unexpected picker failure',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return createCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <RotatePdfState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('changeDirection', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'changes direction',
      build: createCubit,
      act: (cubit) => cubit.changeDirection(RotatePdfDirection.upsideDown),
      expect: () => [
        const RotatePdfState(direction: RotatePdfDirection.upsideDown),
      ],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does nothing when direction is unchanged',
      build: createCubit,
      act: (cubit) => cubit.changeDirection(RotatePdfDirection.clockwise90),
      expect: () => <RotatePdfState>[],
    );
  });

  group('changeScope', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'changes scope',
      build: createCubit,
      act: (cubit) => cubit.changeScope(RotatePdfPageScope.selectedPages),
      expect: () => [
        const RotatePdfState(scope: RotatePdfPageScope.selectedPages),
      ],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does nothing when scope is unchanged',
      build: createCubit,
      act: (cubit) => cubit.changeScope(RotatePdfPageScope.allPages),
      expect: () => <RotatePdfState>[],
    );
  });

  group('updateSelection', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'updates selection',
      build: createCubit,
      act: (cubit) => cubit.updateSelection('1-5,8'),
      expect: () => [const RotatePdfState(selection: '1-5,8')],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'converts null selection to an empty string',
      build: createCubit,
      seed: () => const RotatePdfState(selection: '1-5'),
      act: (cubit) => cubit.updateSelection(null),
      expect: () => [const RotatePdfState()],
    );
  });

  group('updateOutputFileName', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'normalizes the output filename',
      build: createCubit,
      act: (cubit) => cubit.updateOutputFileName('rotated'),
      expect: () => [const RotatePdfState(outputFileName: 'rotated.pdf')],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does not duplicate the pdf extension',
      build: createCubit,
      act: (cubit) => cubit.updateOutputFileName('rotated.pdf'),
      expect: () => [const RotatePdfState(outputFileName: 'rotated.pdf')],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'sets output directory on success',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return createCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        const RotatePdfState(outputDirectory: '/documents/output'),
      ],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does nothing for picker cancellation',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

        return createCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <RotatePdfState>[],
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'notifies an error for an unexpected failure',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return createCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <RotatePdfState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('rotate', () {
    blocTest<RotatePdfCubit, RotatePdfState>(
      'warns when input file is missing',
      build: createCubit,
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateWarningNoFile,
            type: NotificationType.warning,
          ),
        ).called(1);

        verifyNever(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        );
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'warns when output directory is missing',
      build: createCubit,
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'warns when output filename is missing',
      build: createCubit,
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'warns when selected pages have no selection',
      build: createCubit,
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        scope: RotatePdfPageScope.selectedPages,
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateWarningNoSelection,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'warns when page selection is malformed',
      build: createCubit,
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        scope: RotatePdfPageScope.selectedPages,
        selection: 'invalid',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateSelectionInvalid,
            type: NotificationType.warning,
          ),
        ).called(1);

        verifyNever(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        );
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'rotates all pages successfully',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        ).thenAnswer((_) async {
          return File('output/rotated.pdf');
        });

        return createCubit();
      },
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.upsideDown,
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.upsideDown,
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: true,
        ),
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.upsideDown,
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => rotatePdfEngine.rotate(
            inputFile: captureAny(named: 'inputFile'),
            outputFile: captureAny(named: 'outputFile'),
            degrees: captureAny(named: 'degrees'),
            selection: captureAny(named: 'selection'),
          ),
        ).captured;

        expect((captured[0] as File).path, '/documents/sample.pdf');
        expect(
          (captured[1] as File).path,
          '/documents/output${Platform.pathSeparator}rotated.pdf',
        );
        expect(captured[2], 180);
        expect(captured[3], isNull);

        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'rotates selected pages with the correct direction',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        ).thenAnswer((_) async {
          return File('output/rotated.pdf');
        });

        return createCubit();
      },
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.counterClockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1-5,8',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.counterClockwise90,
          scope: RotatePdfPageScope.selectedPages,
          selection: '1-5,8',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: true,
        ),
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.counterClockwise90,
          scope: RotatePdfPageScope.selectedPages,
          selection: '1-5,8',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => rotatePdfEngine.rotate(
            inputFile: captureAny(named: 'inputFile'),
            outputFile: captureAny(named: 'outputFile'),
            degrees: captureAny(named: 'degrees'),
            selection: captureAny(named: 'selection'),
          ),
        ).captured;

        expect(captured[2], 270);
        expect(captured[3], isNotNull);

        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'normalizes trailing output directory separators',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        ).thenAnswer((_) async {
          return File('output/rotated.pdf');
        });

        return createCubit();
      },
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output///',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      verify: (_) {
        final captured = verify(
          () => rotatePdfEngine.rotate(
            inputFile: captureAny(named: 'inputFile'),
            outputFile: captureAny(named: 'outputFile'),
            degrees: captureAny(named: 'degrees'),
            selection: captureAny(named: 'selection'),
          ),
        ).captured;

        expect(
          (captured[1] as File).path,
          '/documents/output${Platform.pathSeparator}rotated.pdf',
        );
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'handles engine failure and resets submitting state',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        ).thenThrow(Exception('rotation failed'));

        return createCubit();
      },
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: true,
        ),
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'handles task submission failure and resets submitting state',
      build: () {
        when(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        ).thenThrow(Exception('task failed'));

        return createCubit();
      },
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
      ),
      act: (cubit) => cubit.rotate(),
      expect: () => [
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: true,
        ),
        const RotatePdfState(
          inputFilePath: '/documents/sample.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'rotated.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsRotateFailed,
            type: NotificationType.error,
          ),
        ).called(1);

        verifyNever(
          () => rotatePdfEngine.rotate(
            inputFile: any(named: 'inputFile'),
            outputFile: any(named: 'outputFile'),
            degrees: any(named: 'degrees'),
            selection: any(named: 'selection'),
          ),
        );
      },
    );

    blocTest<RotatePdfCubit, RotatePdfState>(
      'does nothing when already submitting',
      build: createCubit,
      seed: () => const RotatePdfState(
        inputFilePath: '/documents/sample.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'rotated.pdf',
        isSubmitting: true,
      ),
      act: (cubit) => cubit.rotate(),
      expect: () => <RotatePdfState>[],
      verify: (_) {
        verifyNever(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        );

        verifyNever(
          () => effectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );
  });
}
