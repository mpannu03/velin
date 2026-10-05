import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/compress_pdf/compress_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockCompressPdfEngine extends Mock implements CompressPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockCompressPdfEngine compressPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;
  late CompressPdfCubit cubit;

  setUpAll(() {
    registerFallbackValue(CompressPdfInput(file: File('input.pdf')));
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(File('/documents/output/compressed.pdf'));
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    compressPdfEngine = MockCompressPdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();

    cubit = CompressPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      compressPdfEngine: compressPdfEngine,
      taskManager: taskManager,
      appEffectController: effectController,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('initial state', () {
    test('starts with default state', () {
      expect(cubit.state, const CompressPdfState());
    });
  });

  group('pickFile', () {
    test('updates input and default output values on success', () async {
      const filePath = '/documents/report.pdf';

      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => const Success(filePath));

      await cubit.pickFile();

      expect(cubit.state.inputFilePath, filePath);
      expect(cubit.state.outputDirectory, '/documents/');
      expect(cubit.state.outputFileName, 'report_compressed.pdf');
    });

    test('preserves existing output directory on success', () async {
      const filePath = '/documents/report.pdf';

      cubit.emit(
        const CompressPdfState(
          outputDirectory: '/output',
          outputFileName: 'existing.pdf',
        ),
      );

      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => const Success(filePath));

      await cubit.pickFile();

      expect(cubit.state.inputFilePath, filePath);
      expect(cubit.state.outputDirectory, '/output');
      expect(cubit.state.outputFileName, 'report_compressed.pdf');
    });

    test('stays unchanged when picker is cancelled', () async {
      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => Failure(DocumentFilePickerError('cancelled')));

      await cubit.pickFile();

      expect(cubit.state, const CompressPdfState());
      verifyNever(
        () => effectController.notifyUser(
          message: any(named: 'message'),
          type: any(named: 'type'),
        ),
      );
    });

    test('notifies error when picker fails', () async {
      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => Failure(Exception('picker failed')));

      await cubit.pickFile();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressFailed,
          type: NotificationType.error,
        ),
      ).called(1);
    });
  });

  group('changeQuality', () {
    test('updates quality', () {
      cubit.changeQuality(50);

      expect(cubit.state.quality, 50);
    });

    test('clamps quality below minimum', () {
      cubit.changeQuality(-10);

      expect(cubit.state.quality, CompressPdfToolInput.minQuality);
    });

    test('clamps quality above maximum', () {
      cubit.changeQuality(150);

      expect(cubit.state.quality, CompressPdfToolInput.maxQuality);
    });

    test('does not emit when quality is unchanged', () async {
      final states = <CompressPdfState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.changeQuality(cubit.state.quality);

      await Future<void>.delayed(Duration.zero);

      expect(states, isEmpty);

      await subscription.cancel();
    });
  });

  group('updateOutputFileName', () {
    test('normalizes output filename', () {
      cubit.updateOutputFileName('compressed');

      expect(cubit.state.outputFileName, 'compressed.pdf');
    });

    test('removes duplicate pdf extension', () {
      cubit.updateOutputFileName('compressed.pdf');

      expect(cubit.state.outputFileName, 'compressed.pdf');
    });
  });

  group('pickOutputDirectory', () {
    test('updates output directory on success', () async {
      const directoryPath = '/documents/output';

      when(() => filePicker.pickDirectory())
          .thenAnswer((_) async => const Success(directoryPath));

      await cubit.pickOutputDirectory();

      expect(cubit.state.outputDirectory, directoryPath);
    });

    test('stays unchanged when picker is cancelled', () async {
      when(
        () => filePicker.pickDirectory(),
      ).thenAnswer((_) async => Failure(DocumentFilePickerError('cancelled')));

      await cubit.pickOutputDirectory();

      expect(cubit.state.outputDirectory, isNull);

      verifyNever(
        () => effectController.notifyUser(
          message: any(named: 'message'),
          type: any(named: 'type'),
        ),
      );
    });

    test('notifies error when picker fails', () async {
      when(() => filePicker.pickDirectory())
          .thenAnswer((_) async => Failure(Exception('picker failed')));

      await cubit.pickOutputDirectory();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressFailed,
          type: NotificationType.error,
        ),
      ).called(1);
    });
  });

  group('compress', () {
    test('warns when input file is missing', () async {
      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressWarningNoFile,
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
    });

    test('warns when output directory is missing', () async {
      cubit.emit(const CompressPdfState(inputFilePath: '/documents/input.pdf'));

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressWarningNoFolder,
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
    });

    test('warns when output filename is missing', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
        ),
      );

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressWarningNoFileName,
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
    });

    test('submits compression task with correct input', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
          quality: 60,
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenAnswer((invocation) async {
        return Future.value(File('/documents/output/compressed.pdf'));
      });

      await cubit.compress();

      final captured = verify(
        () => compressPdfEngine.compress(
          input: captureAny(named: 'input'),
          outputFile: captureAny(named: 'outputFile'),
        ),
      ).captured;

      final input = captured[0] as CompressPdfInput;
      final outputFile = captured[1] as File;

      expect(input.file.path, '/documents/input.pdf');
      expect(input.compressionLevel, 60);
      expect(outputFile.path, isNotEmpty);

      verify(
        () => taskManager.submit(
          id: any(named: 'id', that: startsWith('compress-pdf-')),
          title: l10n.toolsCompressButton,
          operation: any(named: 'operation'),
        ),
      ).called(1);
    });

    test('notifies success after compression', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenAnswer((_) async {
        return File('/documents/output/compressed.pdf');
      });

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressSuccess,
          type: NotificationType.success,
        ),
      ).called(1);
    });

    test('warns when the PDF is encrypted', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenThrow(UnsupportedError('encrypted'));

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressEncrypted,
          type: NotificationType.warning,
        ),
      ).called(1);
    });

    test('warns when input and output paths are the same', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'input.pdf',
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenThrow(ArgumentError('same file'));

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressWarningNoFileName,
          type: NotificationType.warning,
        ),
      ).called(1);
    });

    test('notifies error for unexpected compression failure', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenThrow(Exception('compression failed'));

      await cubit.compress();

      verify(
        () => effectController.notifyUser(
          message: l10n.toolsCompressFailed,
          type: NotificationType.error,
        ),
      ).called(1);
    });

    test('resets submitting state after success', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
        ),
      );

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
        () => compressPdfEngine.compress(
          input: any(named: 'input'),
          outputFile: any(named: 'outputFile'),
        ),
      ).thenAnswer((_) async {
        return File('/documents/output/compressed.pdf');
      });

      await cubit.compress();

      expect(cubit.state.isSubmitting, isFalse);
    });

    test('resets submitting state after failure', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
        ),
      );

      when(
        () => taskManager.submit(
          id: any(named: 'id'),
          title: any(named: 'title'),
          operation: any(named: 'operation'),
        ),
      ).thenThrow(Exception('submit failed'));

      await cubit.compress();

      expect(cubit.state.isSubmitting, isFalse);
    });

    test('does nothing when already submitting', () async {
      cubit.emit(
        const CompressPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'compressed.pdf',
          isSubmitting: true,
        ),
      );

      await cubit.compress();

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
    });
  });
}
