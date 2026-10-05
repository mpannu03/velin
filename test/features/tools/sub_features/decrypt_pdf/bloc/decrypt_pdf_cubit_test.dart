import 'dart:io';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf_cos/pdf_cos.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/decrypt_pdf/decrypt_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockDecryptPdfEngine extends Mock implements DecryptPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockDecryptPdfEngine decryptPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;

  DecryptPdfCubit buildCubit() {
    return DecryptPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      decryptPdfEngine: decryptPdfEngine,
      taskManager: taskManager,
      appEffectController: effectController,
    );
  }

  setUpAll(() {
    registerFallbackValue(NotificationType.error);
    registerFallbackValue(
      DecryptPdfInput(
        inputFile: File('input.pdf'),
        outputFile: File('output.pdf'),
      ),
    );
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    decryptPdfEngine = MockDecryptPdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();
  });

  group('initial state', () {
    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'starts with default state',
      build: buildCubit,
      expect: () => [],
      verify: (cubit) {
        expect(cubit.state, const DecryptPdfState());
      },
    );
  });

  group('pickFile', () {
    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'sets input and default output values on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/protected.pdf'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/documents/',
          outputFileName: 'protected_unlocked.pdf',
        ),
      ],
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'preserves existing output directory on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/protected.pdf'));

        return buildCubit();
      },
      seed: () => const DecryptPdfState(
        outputDirectory: '/output',
        outputFileName: 'existing.pdf',
      ),
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const DecryptPdfState(
          inputFilePath: '/documents/protected.pdf',
          outputDirectory: '/output',
          outputFileName: 'protected_unlocked.pdf',
        ),
      ],
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'does not change state when picker is cancelled',
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

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'notifies error when picker fails',
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
            message: l10n.toolsUnlockFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('updatePassword', () {
    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'updates password',
      build: buildCubit,
      act: (cubit) => cubit.updatePassword('secret'),
      expect: () => [const DecryptPdfState(password: 'secret')],
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'clears password when null is provided',
      build: buildCubit,
      seed: () => const DecryptPdfState(password: 'secret'),
      act: (cubit) => cubit.updatePassword(null),
      expect: () => [const DecryptPdfState(password: '')],
    );
  });

  group('updateOutputFileName', () {
    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'normalizes output filename',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('unlocked'),
      expect: () => [const DecryptPdfState(outputFileName: 'unlocked.pdf')],
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'keeps a valid pdf extension',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('unlocked.pdf'),
      expect: () => [const DecryptPdfState(outputFileName: 'unlocked.pdf')],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'sets output directory on success',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        const DecryptPdfState(outputDirectory: '/documents/output'),
      ],
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'does not change state when picker is cancelled',
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

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'notifies error when directory picker fails',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => Failure(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('unlock', () {
    const validState = DecryptPdfState(
      inputFilePath: '/documents/protected.pdf',
      outputDirectory: '/documents/output',
      outputFileName: 'unlocked.pdf',
      password: 'secret',
    );

    void stubSuccessfulTask() {
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

      when(() => decryptPdfEngine.decrypt(any())).thenAnswer((_) async {
        return File('/documents/unlocked.pdf');
      });
    }

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'warns when input file is missing',
      build: buildCubit,
      act: (cubit) => cubit.unlock(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockWarningNoFile,
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

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'warns when output directory is missing',
      build: buildCubit,
      seed: () => const DecryptPdfState(
        inputFilePath: '/documents/protected.pdf',
        outputFileName: 'unlocked.pdf',
      ),
      act: (cubit) => cubit.unlock(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockWarningNoFolder,
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

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'warns when output filename is missing',
      build: buildCubit,
      seed: () => const DecryptPdfState(
        inputFilePath: '/documents/protected.pdf',
        outputDirectory: '/documents/output',
      ),
      act: (cubit) => cubit.unlock(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockWarningNoFileName,
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

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'submits the correct engine input',
      build: () {
        stubSuccessfulTask();
        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        final input =
            verify(() => decryptPdfEngine.decrypt(captureAny())).captured.single
                as DecryptPdfInput;

        expect(input.inputFile.path, '/documents/protected.pdf');
        expect(input.outputFile.path, isNotEmpty);
        expect(input.password, 'secret');

        verify(
          () => taskManager.submit(
            id: any(named: 'id', that: startsWith('decrypt-pdf-')),
            title: l10n.toolsUnlockButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'notifies success after successful decryption',
      build: () {
        stubSuccessfulTask();
        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'warns when password is incorrect',
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

        when(() => decryptPdfEngine.decrypt(any()))
            .thenThrow(CosPasswordException());

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockWrongPassword,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'warns when PDF is not encrypted',
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

        when(() => decryptPdfEngine.decrypt(any()))
            .thenThrow(StateError('document is not encrypted'));

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockNotEncrypted,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'notifies error for unexpected failure',
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

        when(() => decryptPdfEngine.decrypt(any()))
            .thenThrow(Exception('decryption failed'));

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'resets submitting state when task submission itself fails',
      build: () {
        when(
          () => taskManager.submit(
            id: any(named: 'id'),
            title: any(named: 'title'),
            operation: any(named: 'operation'),
          ),
        ).thenThrow(Exception('submit failed'));

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.unlock(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsUnlockFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<DecryptPdfCubit, DecryptPdfState>(
      'does nothing when already submitting',
      build: buildCubit,
      seed: () => validState.copyWith(isSubmitting: true),
      act: (cubit) => cubit.unlock(),
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
