import 'dart:io';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/extract_pdf/extract_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockExtractPdfEngine extends Mock implements ExtractPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockExtractPdfEngine extractPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(File('input.pdf'));
    registerFallbackValue(PageSelection([]));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    extractPdfEngine = MockExtractPdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();
  });

  ExtractPdfCubit buildCubit() {
    return ExtractPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      extractPdfEngine: extractPdfEngine,
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

  group('pickFile', () {
    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'sets file and default output values when picking succeeds',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/sample.pdf'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const ExtractPdfState(
          filePath: '/documents/sample.pdf',
          outputDirectory: '/documents/',
          outputFileName: 'sample_extracted.pdf',
        ),
      ],
      verify: (_) {
        verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'preserves existing output directory when picking a new file',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/other.pdf'));

        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(const ExtractPdfState(outputDirectory: '/custom/output'));
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const ExtractPdfState(
          filePath: '/documents/other.pdf',
          outputDirectory: '/custom/output',
          outputFileName: 'other_extracted.pdf',
        ),
      ],
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'stays unchanged when picker is cancelled',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
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

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'notifies an error for an unexpected picker failure',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('updateSelection', () {
    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'updates page selection',
      build: buildCubit,
      act: (cubit) => cubit.updateSelection('1-5,8'),
      expect: () => [const ExtractPdfState(pageSelection: '1-5,8')],
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'allows page selection to be cleared',
      build: () {
        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(const ExtractPdfState(pageSelection: '1-5'));
      },
      act: (cubit) => cubit.updateSelection(null),
      expect: () => [const ExtractPdfState()],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'updates output directory when picking succeeds',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        const ExtractPdfState(outputDirectory: '/documents/output'),
      ],
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'stays unchanged when directory picker is cancelled',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async => Failure(DocumentFilePickerError('cancelled')),
        );

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

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'notifies an error for an unexpected directory picker failure',
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
            message: l10n.toolsExtractFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('updateOutputFileName', () {
    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'normalizes the output file name',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('extracted'),
      expect: () => [const ExtractPdfState(outputFileName: 'extracted.pdf')],
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'clears the output file name when null is supplied',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName(null),
      expect: () => [const ExtractPdfState(outputFileName: '')],
    );
  });

  group('extract', () {
    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'warns when input file is missing',
      build: buildCubit,
      act: (cubit) => cubit.extract(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractWarningNoFile,
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

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'warns when output directory is missing',
      build: () =>
          ExtractPdfCubit(
            l10n: l10n,
            filePicker: filePicker,
            extractPdfEngine: extractPdfEngine,
            taskManager: taskManager,
            appEffectController: effectController,
          )..emit(
            const ExtractPdfState(
              filePath: '/documents/source.pdf',
              outputFileName: 'extracted.pdf',
            ),
          ),
      act: (cubit) => cubit.extract(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'warns when output file name is missing',
      build: () =>
          ExtractPdfCubit(
            l10n: l10n,
            filePicker: filePicker,
            extractPdfEngine: extractPdfEngine,
            taskManager: taskManager,
            appEffectController: effectController,
          )..emit(
            const ExtractPdfState(
              filePath: '/documents/source.pdf',
              outputDirectory: '/documents',
            ),
          ),
      act: (cubit) => cubit.extract(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'warns when page selection is invalid',
      build: () =>
          ExtractPdfCubit(
            l10n: l10n,
            filePicker: filePicker,
            extractPdfEngine: extractPdfEngine,
            taskManager: taskManager,
            appEffectController: effectController,
          )..emit(
            const ExtractPdfState(
              filePath: '/documents/source.pdf',
              pageSelection: 'invalid',
              outputDirectory: '/documents',
              outputFileName: 'extracted.pdf',
            ),
          ),
      act: (cubit) => cubit.extract(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractSelectionInvalid,
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

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'submits extraction and resets submitting state',
      build: () {
        when(
          () => extractPdfEngine.extract(
            inputFile: any(named: 'inputFile'),
            selection: any(named: 'selection'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenAnswer((_) async {
          return File('/documents/extracted.pdf');
        });

        stubSuccessfulTaskSubmission();

        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(
          const ExtractPdfState(
            filePath: '/documents/source.pdf',
            pageSelection: '1-3,5',
            outputDirectory: '/documents/',
            outputFileName: 'extracted.pdf',
          ),
        );
      },
      act: (cubit) => cubit.extract(),
      expect: () => [
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-3,5',
          outputDirectory: '/documents/',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        ),
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-3,5',
          outputDirectory: '/documents/',
          outputFileName: 'extracted.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => extractPdfEngine.extract(
            inputFile: captureAny(named: 'inputFile'),
            selection: captureAny(named: 'selection'),
            outputFile: captureAny(named: 'outputFile'),
          ),
        ).captured;

        expect(captured[0], isA<File>());
        expect(captured[1], isA<PageSelection>());
        expect(captured[2], isA<File>());

        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractSuccess,
            type: NotificationType.success,
          ),
        ).called(1);

        verify(
          () => taskManager.submit(
            id: any(named: 'id', that: startsWith('extract-pdf-')),
            title: l10n.toolsExtractButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'normalizes trailing output directory separators',
      build: () {
        when(
          () => extractPdfEngine.extract(
            inputFile: any(named: 'inputFile'),
            selection: any(named: 'selection'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenAnswer((_) async {
          return File('/documents/output/pages.pdf');
        });

        stubSuccessfulTaskSubmission();

        final sep = Platform.pathSeparator;

        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(
          ExtractPdfState(
            filePath: '${sep}documents${sep}source.pdf',
            pageSelection: '2',
            outputDirectory: '${sep}documents${sep}output$sep$sep$sep',
            outputFileName: 'pages.pdf',
          ),
        );
      },
      act: (cubit) => cubit.extract(),
      verify: (_) {
        final sep = Platform.pathSeparator;

        final outputFile =
            verify(
                  () => extractPdfEngine.extract(
                    inputFile: any(named: 'inputFile'),
                    selection: any(named: 'selection'),
                    outputFile: captureAny(named: 'outputFile'),
                  ),
                ).captured.single
                as File;

        expect(outputFile.path, '${sep}documents${sep}output${sep}pages.pdf');
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'notifies an error when extraction fails',
      build: () {
        when(
          () => extractPdfEngine.extract(
            inputFile: any(named: 'inputFile'),
            selection: any(named: 'selection'),
            outputFile: any(named: 'outputFile'),
          ),
        ).thenThrow(Exception('extraction failed'));

        stubSuccessfulTaskSubmission();

        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(
          const ExtractPdfState(
            filePath: '/documents/source.pdf',
            pageSelection: '1-3',
            outputDirectory: '/documents',
            outputFileName: 'extracted.pdf',
          ),
        );
      },
      act: (cubit) => cubit.extract(),
      expect: () => [
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-3',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        ),
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1-3',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'notifies an error when task submission fails',
      build: () {
        when(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        ).thenThrow(Exception('task submission failed'));

        return ExtractPdfCubit(
          l10n: l10n,
          filePicker: filePicker,
          extractPdfEngine: extractPdfEngine,
          taskManager: taskManager,
          appEffectController: effectController,
        )..emit(
          const ExtractPdfState(
            filePath: '/documents/source.pdf',
            pageSelection: '1',
            outputDirectory: '/documents',
            outputFileName: 'extracted.pdf',
          ),
        );
      },
      act: (cubit) => cubit.extract(),
      expect: () => [
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: true,
        ),
        const ExtractPdfState(
          filePath: '/documents/source.pdf',
          pageSelection: '1',
          outputDirectory: '/documents',
          outputFileName: 'extracted.pdf',
          isSubmitting: false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsExtractFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<ExtractPdfCubit, ExtractPdfState>(
      'does nothing when already submitting',
      build: () =>
          ExtractPdfCubit(
            l10n: l10n,
            filePicker: filePicker,
            extractPdfEngine: extractPdfEngine,
            taskManager: taskManager,
            appEffectController: effectController,
          )..emit(
            const ExtractPdfState(
              filePath: '/documents/source.pdf',
              pageSelection: '1',
              outputDirectory: '/documents',
              outputFileName: 'extracted.pdf',
              isSubmitting: true,
            ),
          ),
      act: (cubit) => cubit.extract(),
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
          () => extractPdfEngine.extract(
            inputFile: any(named: 'inputFile'),
            selection: any(named: 'selection'),
            outputFile: any(named: 'outputFile'),
          ),
        );
      },
    );
  });
}
