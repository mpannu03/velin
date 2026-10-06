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
import 'package:velin/features/tools/sub_features/merge_pdf/bloc/bloc.dart';
import 'package:velin/l10n/app_localizations.dart';
import 'package:velin/shared/utils/utils.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockMergePdfEngine extends Mock implements MergePdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockMergePdfEngine mergePdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(MergePdfToolInput(filePath: '/test.pdf'));
    registerFallbackValue(File('/output/result.pdf'));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    mergePdfEngine = MockMergePdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();

    when(
      () => effectController.notifyUser(
        message: any(named: 'message'),
        type: any(named: 'type'),
      ),
    ).thenReturn(null);
  });

  MergePdfCubit buildCubit() {
    return MergePdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      mergePdfEngine: mergePdfEngine,
      taskManager: taskManager,
      appEffectController: effectController,
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

  group('pickFiles', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'adds selected files and sets output directory from first file',
      build: () {
        when(() => filePicker.pickFiles(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async =>
              const Success(['/documents/one.pdf', '/documents/two.pdf']),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickFiles(),
      expect: () => [
        MergePdfState(
          inputs: const [
            MergePdfToolInput(filePath: '/documents/one.pdf'),
            MergePdfToolInput(filePath: '/documents/two.pdf'),
          ],
          outputDirectory: directoryWithTrailingSeparator('/documents/one.pdf'),
        ),
      ],
      verify: (_) {
        verify(() => filePicker.pickFiles(allowedExtensions: ['pdf']))
            .called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'appends selected files to existing inputs',
      build: () {
        when(() => filePicker.pickFiles(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success(['/documents/two.pdf']));

        return MergePdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          mergePdfEngine: mergePdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(
          const MergePdfState(
            inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
            outputDirectory: '/output',
          ),
        );
      },
      act: (cubit) => cubit.pickFiles(),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(filePath: '/documents/one.pdf'),
            MergePdfToolInput(filePath: '/documents/two.pdf'),
          ],
          outputDirectory: '/output',
        ),
      ],
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'does not emit when picker returns an empty list',
      build: () {
        when(() => filePicker.pickFiles(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success([]));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFiles(),
      expect: () => [],
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'does not emit when picker is cancelled',
      build: () {
        when(
          () => filePicker.pickFiles(allowedExtensions: ['pdf']),
        ).thenAnswer((_) async => Failure(DocumentFilePickerError('canceled')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFiles(),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => effectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'notifies error for unexpected picker failure',
      build: () {
        when(() => filePicker.pickFiles(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFiles(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('removeFile', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'removes file at index',
      build: () => buildCubit(),
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: '/documents/one.pdf'),
          MergePdfToolInput(filePath: '/documents/two.pdf'),
          MergePdfToolInput(filePath: '/documents/three.pdf'),
        ],
      ),
      act: (cubit) => cubit.removeFile(1),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(filePath: '/documents/one.pdf'),
            MergePdfToolInput(filePath: '/documents/three.pdf'),
          ],
        ),
      ],
    );
  });

  group('reorderFiles', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'moves file to the new index',
      build: () => buildCubit(),
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: '/documents/one.pdf'),
          MergePdfToolInput(filePath: '/documents/two.pdf'),
          MergePdfToolInput(filePath: '/documents/three.pdf'),
        ],
      ),
      act: (cubit) => cubit.reorderFiles(0, 2),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(filePath: '/documents/two.pdf'),
            MergePdfToolInput(filePath: '/documents/three.pdf'),
            MergePdfToolInput(filePath: '/documents/one.pdf'),
          ],
        ),
      ],
    );
  });

  group('updatePageSelection', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'updates page selection for the requested file',
      build: () => buildCubit(),
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: '/documents/one.pdf'),
          MergePdfToolInput(filePath: '/documents/two.pdf'),
        ],
      ),
      act: (cubit) => cubit.updatePageSelection(1, '2-5'),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(filePath: '/documents/one.pdf'),
            MergePdfToolInput(
              filePath: '/documents/two.pdf',
              pageSelection: '2-5',
            ),
          ],
        ),
      ],
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'can replace an existing page selection',
      build: () => buildCubit(),
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(
            filePath: '/documents/one.pdf',
            pageSelection: '1-5',
          ),
        ],
      ),
      act: (cubit) => cubit.updatePageSelection(0, 'odd'),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(
              filePath: '/documents/one.pdf',
              pageSelection: 'odd',
            ),
          ],
        ),
      ],
    );
  });

  group('updateOutputFileName', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'normalizes output file name',
      build: () => buildCubit(),
      act: (cubit) => cubit.updateOutputFileName('merged'),
      expect: () => [const MergePdfState(outputFileName: 'merged.pdf')],
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'preserves an existing pdf extension',
      build: () => buildCubit(),
      act: (cubit) => cubit.updateOutputFileName('final.pdf'),
      expect: () => [const MergePdfState(outputFileName: 'final.pdf')],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'updates output directory on success',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [const MergePdfState(outputDirectory: '/output')],
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'does not emit when directory picker is cancelled',
      build: () {
        when(
          () => filePicker.pickDirectory(),
        ).thenAnswer((_) async => Failure(DocumentFilePickerError('canceled')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => effectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'notifies error for unexpected directory picker failure',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(Exception('directory picker failed')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('merge', () {
    blocTest<MergePdfCubit, MergePdfState>(
      'warns when no input files are selected',
      build: buildCubit,
      act: (cubit) => cubit.merge(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeWarningNoFiles,
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

    blocTest<MergePdfCubit, MergePdfState>(
      'warns when output directory is missing',
      build: buildCubit,
      seed: () => const MergePdfState(
        inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'warns when output file name is empty',
      build: buildCubit,
      seed: () => const MergePdfState(
        inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
        outputDirectory: '/output',
        outputFileName: '',
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'warns when a page selection is invalid',
      build: buildCubit,
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(filePath: 'one.pdf', pageSelection: 'not-valid'),
        ],
        outputDirectory: '/output',
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergePageSelectionInvalid('one.pdf'),
            type: NotificationType.error,
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

    blocTest<MergePdfCubit, MergePdfState>(
      'merges successfully with mapped inputs and output file',
      build: () {
        stubSuccessfulTaskSubmission();

        when(
          () => mergePdfEngine.merge(
            inputs: any(named: 'inputs'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenAnswer((_) async {
          return File('/output/result.pdf');
        });

        return buildCubit();
      },
      seed: () => const MergePdfState(
        inputs: [
          MergePdfToolInput(
            filePath: '/documents/one.pdf',
            pageSelection: '1-5',
          ),
          MergePdfToolInput(filePath: '/documents/two.pdf'),
        ],
        outputDirectory: '/output',
        outputFileName: 'result.pdf',
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [
        const MergePdfState(
          inputs: [
            MergePdfToolInput(
              filePath: '/documents/one.pdf',
              pageSelection: '1-5',
            ),
            MergePdfToolInput(filePath: '/documents/two.pdf'),
          ],
          outputDirectory: '/output',
          outputFileName: 'result.pdf',
          isSubmitting: true,
        ),
        const MergePdfState(
          inputs: [
            MergePdfToolInput(
              filePath: '/documents/one.pdf',
              pageSelection: '1-5',
            ),
            MergePdfToolInput(filePath: '/documents/two.pdf'),
          ],
          outputDirectory: '/output',
          outputFileName: 'result.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => mergePdfEngine.merge(
            inputs: captureAny(named: 'inputs'),
            outputFile: captureAny(named: 'outputFile'),
          ),
        ).captured;

        final inputs = captured[0] as List<MergePdfInput>;
        final outputFile = captured[1] as File;

        expect(inputs, hasLength(2));
        expect(inputs[0].file.path, '/documents/one.pdf');
        expect(inputs[0].selection, isNotNull);
        expect(inputs[1].file.path, '/documents/two.pdf');
        expect(inputs[1].selection, isNull);

        expect(
          outputFile.path,
          '${'/output'}${Platform.pathSeparator}result.pdf',
        );

        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'notifies error when engine fails',
      build: () {
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
          () => mergePdfEngine.merge(
            inputs: any(named: 'inputs'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenThrow(Exception('merge failed'));

        return buildCubit();
      },
      seed: () => const MergePdfState(
        inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
        outputDirectory: '/output',
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [
        const MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
          outputDirectory: '/output',
          isSubmitting: true,
        ),
        const MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
          outputDirectory: '/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'notifies error when task submission fails',
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
      seed: () => const MergePdfState(
        inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
        outputDirectory: '/output',
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [
        const MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
          outputDirectory: '/output',
          isSubmitting: true,
        ),
        const MergePdfState(
          inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
          outputDirectory: '/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsMergeFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<MergePdfCubit, MergePdfState>(
      'does nothing when already submitting',
      build: buildCubit,
      seed: () => const MergePdfState(
        inputs: [MergePdfToolInput(filePath: '/documents/one.pdf')],
        outputDirectory: '/output',
        isSubmitting: true,
      ),
      act: (cubit) => cubit.merge(),
      expect: () => [],
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
