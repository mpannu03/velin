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

class MockSplitPdfEngine extends Mock implements SplitPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockSplitPdfEngine splitPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController appEffectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(File('input.pdf'));
    registerFallbackValue(SplitPdfToolInput(filePath: '/documents/input.pdf'));
    registerFallbackValue(
      SplitPdfInput(file: File('input.pdf'), mode: SplitPdfMode.byPageCount),
    );
    registerFallbackValue(Directory('/documents/output'));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    splitPdfEngine = MockSplitPdfEngine();
    taskManager = MockTaskManager();
    appEffectController = MockAppEffectController();

    when(
      () => appEffectController.notifyUser(
        message: any(named: 'message'),
        type: any(named: 'type'),
      ),
    ).thenReturn(null);
  });

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

  SplitPdfCubit buildCubit() {
    return SplitPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      splitPdfEngine: splitPdfEngine,
      taskManager: taskManager,
      appEffectController: appEffectController,
    );
  }

  group('pickFile', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'sets input file and default output directory',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/input.pdf'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/',
        ),
      ],
      verify: (_) {
        verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'preserves an existing output directory',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/input.pdf'));

        return SplitPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          splitPdfEngine: splitPdfEngine,
          taskManager: taskManager,
          appEffectController: appEffectController,
        )..emit(const SplitPdfState(outputDirectory: '/documents/output'));
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
        ),
      ],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does not change state for picker cancellation',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async => Failure(const DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'notifies an unexpected file picker failure',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('changeMode', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'changes the split mode',
      build: buildCubit,
      act: (cubit) => cubit.changeMode(SplitPdfMode.bySelection),
      expect: () => [const SplitPdfState(mode: SplitPdfMode.bySelection)],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does not emit when mode is unchanged',
      build: buildCubit,
      act: (cubit) => cubit.changeMode(SplitPdfMode.byPageCount),
      expect: () => <SplitPdfState>[],
    );
  });

  group('updatePageCount', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'updates page count text',
      build: buildCubit,
      act: (cubit) => cubit.updatePageCount('25'),
      expect: () => [const SplitPdfState(pageCount: '25')],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'preserves raw page count input',
      build: buildCubit,
      act: (cubit) => cubit.updatePageCount(' 25 '),
      expect: () => [const SplitPdfState(pageCount: ' 25 ')],
    );
  });

  group('addSelection', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'adds an empty selection',
      build: buildCubit,
      act: (cubit) => cubit.addSelection(),
      expect: () => [
        const SplitPdfState(selections: ['']),
      ],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'appends an empty selection without changing existing selections',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5', '10']),
      act: (cubit) => cubit.addSelection(),
      expect: () => [
        const SplitPdfState(selections: ['1-5', '10', '']),
      ],
    );
  });

  group('updateSelection', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'updates the selection at the requested index',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5', '10']),
      act: (cubit) => cubit.updateSelection(1, '20'),
      expect: () => [
        const SplitPdfState(selections: ['1-5', '20']),
      ],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does nothing for a negative index',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5']),
      act: (cubit) => cubit.updateSelection(-1, '10'),
      expect: () => <SplitPdfState>[],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does nothing for an index past the end',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5']),
      act: (cubit) => cubit.updateSelection(1, '10'),
      expect: () => <SplitPdfState>[],
    );
  });

  group('removeSelection', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'removes the selection at the requested index',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5', '10', 'odd']),
      act: (cubit) => cubit.removeSelection(1),
      expect: () => [
        const SplitPdfState(selections: ['1-5', 'odd']),
      ],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does nothing for a negative index',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5']),
      act: (cubit) => cubit.removeSelection(-1),
      expect: () => <SplitPdfState>[],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does nothing for an index past the end',
      build: buildCubit,
      seed: () => const SplitPdfState(selections: ['1-5']),
      act: (cubit) => cubit.removeSelection(1),
      expect: () => <SplitPdfState>[],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'sets the output directory',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [const SplitPdfState(outputDirectory: '/documents/output')],
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does not change state for picker cancellation',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(const DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verifyNever(
          () => appEffectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'notifies an unexpected directory picker failure',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('split validation', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'warns when no input file is selected',
      build: buildCubit,
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitWarningNoFile,
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

    blocTest<SplitPdfCubit, SplitPdfState>(
      'warns when no output directory is selected',
      build: buildCubit,
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '10',
      ),
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'warns when page count is invalid',
      build: buildCubit,
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '0',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitWarningPagesPerFile,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'warns when selection list is empty',
      build: buildCubit,
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.bySelection,
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitWarningNoSelection,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'reports an invalid page selection',
      build: buildCubit,
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.bySelection,
        selections: ['invalid'],
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitSelectionInvalid,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('split', () {
    blocTest<SplitPdfCubit, SplitPdfState>(
      'splits by page count successfully',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenAnswer(
          (_) async => [
            File('/documents/output/input-1.pdf'),
            File('/documents/output/input-2.pdf'),
            File('/documents/output/input-3.pdf'),
          ],
        );

        return buildCubit();
      },
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.byPageCount,
        pageCount: '10',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.byPageCount,
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.byPageCount,
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => splitPdfEngine.split(
            input: captureAny(named: 'input'),
            outputDirectory: captureAny(named: 'outputDirectory'),
          ),
        ).captured;

        final input = captured[0] as SplitPdfInput;
        final outputDirectory = captured[1] as Directory;

        expect(input.mode, SplitPdfMode.byPageCount);
        expect(input.file.path, '/documents/input.pdf');
        expect(input.pageCount, 10);
        expect(outputDirectory.path, '/documents/output');

        verify(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: l10n.toolsSplitButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitSuccess(3),
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'splits by selection successfully',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenAnswer(
          (_) async => [
            File('/documents/output/input-1.pdf'),
            File('/documents/output/input-2.pdf'),
          ],
        );

        return buildCubit();
      },
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.bySelection,
        selections: ['1-5', '10', 'odd'],
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.bySelection,
          selections: ['1-5', '10', 'odd'],
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.bySelection,
          selections: ['1-5', '10', 'odd'],
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => splitPdfEngine.split(
            input: captureAny(named: 'input'),
            outputDirectory: captureAny(named: 'outputDirectory'),
          ),
        ).captured;

        final input = captured[0] as SplitPdfInput;

        expect(input.mode, SplitPdfMode.bySelection);
        expect(input.selections, hasLength(3));

        expect(input.selections[0].resolve(20), [1, 2, 3, 4, 5]);
        expect(input.selections[1].resolve(20), [10]);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitSuccess(2),
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'extracts all pages successfully',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenAnswer((_) async => [File('/documents/output/input.pdf')]);

        return buildCubit();
      },
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        mode: SplitPdfMode.extractAllPages,
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.extractAllPages,
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          mode: SplitPdfMode.extractAllPages,
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => splitPdfEngine.split(
            input: captureAny(named: 'input'),
            outputDirectory: captureAny(named: 'outputDirectory'),
          ),
        ).captured;

        final input = captured[0] as SplitPdfInput;

        expect(input.mode, SplitPdfMode.extractAllPages);
        expect(input.selections, isEmpty);
        expect(input.pageCount, isNull);

        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitSuccess(1),
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'resets submitting state when the engine fails',
      build: () {
        stubTaskManagerToRunOperation();

        when(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        ).thenThrow(Exception('split failed'));

        return buildCubit();
      },
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '10',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'resets submitting state when task submission fails',
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
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '10',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.split(),
      expect: () => [
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: true,
        ),
        const SplitPdfState(
          inputFilePath: '/documents/input.pdf',
          pageCount: '10',
          outputDirectory: '/documents/output',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => appEffectController.notifyUser(
            message: l10n.toolsSplitFailed,
            type: NotificationType.error,
          ),
        ).called(1);

        verifyNever(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        );
      },
    );

    blocTest<SplitPdfCubit, SplitPdfState>(
      'does nothing when already submitting',
      build: buildCubit,
      seed: () => const SplitPdfState(
        inputFilePath: '/documents/input.pdf',
        pageCount: '10',
        outputDirectory: '/documents/output',
        isSubmitting: true,
      ),
      act: (cubit) => cubit.split(),
      expect: () => <SplitPdfState>[],
      verify: (_) {
        verifyNever(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        );
        verifyNever(
          () => splitPdfEngine.split(
            input: any(named: 'input'),
            outputDirectory: any(named: 'outputDirectory'),
          ),
        );
      },
    );
  });
}
