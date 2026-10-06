import 'dart:io';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart' hide PdfPermissions;
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/encrypt_pdf/encrypt_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockEncryptPdfEngine extends Mock implements EncryptPdfEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late AppLocalizations l10n;
  late MockDocumentFilePicker filePicker;
  late MockEncryptPdfEngine encryptPdfEngine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;

  EncryptPdfCubit buildCubit() {
    return EncryptPdfCubit(
      l10n: l10n,
      filePicker: filePicker,
      encryptPdfEngine: encryptPdfEngine,
      taskManager: taskManager,
      appEffectController: effectController,
    );
  }

  setUpAll(() {
    registerFallbackValue(
      EncryptPdfInput(
        inputFile: File('input.pdf'),
        outputFile: File('output.pdf'),
        ownerPassword: '',
      ),
    );
    registerFallbackValue(NotificationType.error);
  });

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
    filePicker = MockDocumentFilePicker();
    encryptPdfEngine = MockEncryptPdfEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();
  });

  group('initial state', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'starts with default state',
      build: buildCubit,
      expect: () => [],
      verify: (cubit) {
        expect(cubit.state, const EncryptPdfState());
      },
    );
  });

  group('pickFile', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'sets input and default output values on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/input.pdf'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/',
          outputFileName: 'input_protected.pdf',
        ),
      ],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'preserves existing output directory on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/input.pdf'));

        return buildCubit();
      },
      seed: () => const EncryptPdfState(
        outputDirectory: '/output',
        outputFileName: 'existing.pdf',
      ),
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        const EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/output',
          outputFileName: 'input_protected.pdf',
        ),
      ],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
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

    blocTest<EncryptPdfCubit, EncryptPdfState>(
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
            message: l10n.toolsProtectFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('updateUserPassword', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'updates user password',
      build: buildCubit,
      act: (cubit) => cubit.updateUserPassword('user-secret'),
      expect: () => [const EncryptPdfState(userPassword: 'user-secret')],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'clears user password when null is provided',
      build: buildCubit,
      seed: () => const EncryptPdfState(userPassword: 'user-secret'),
      act: (cubit) => cubit.updateUserPassword(null),
      expect: () => [const EncryptPdfState()],
    );
  });

  group('updateOwnerPassword', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'updates owner password',
      build: buildCubit,
      act: (cubit) => cubit.updateOwnerPassword('owner-secret'),
      expect: () => [const EncryptPdfState(ownerPassword: 'owner-secret')],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'clears owner password when null is provided',
      build: buildCubit,
      seed: () => const EncryptPdfState(ownerPassword: 'owner-secret'),
      act: (cubit) => cubit.updateOwnerPassword(null),
      expect: () => [const EncryptPdfState()],
    );
  });

  group('changeLevel', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'changes encryption level',
      build: buildCubit,
      act: (cubit) => cubit.changeLevel(EncryptPdfEncryptionLevel.aes128),
      expect: () => [
        const EncryptPdfState(level: EncryptPdfEncryptionLevel.aes128),
      ],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'does not emit when level is unchanged',
      build: buildCubit,
      act: (cubit) => cubit.changeLevel(EncryptPdfEncryptionLevel.aes256),
      expect: () => [],
    );
  });

  group('changePermissions', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'changes permission preset',
      build: buildCubit,
      act: (cubit) =>
          cubit.changePermissions(EncryptPdfPermissionPreset.readOnly),
      expect: () => [
        const EncryptPdfState(permissions: EncryptPdfPermissionPreset.readOnly),
      ],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'does not emit when permissions are unchanged',
      build: buildCubit,
      act: (cubit) => cubit.changePermissions(EncryptPdfPermissionPreset.all),
      expect: () => [],
    );
  });

  group('updateOutputFileName', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'normalizes output filename',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('protected'),
      expect: () => [const EncryptPdfState(outputFileName: 'protected.pdf')],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'keeps a valid pdf extension',
      build: buildCubit,
      act: (cubit) => cubit.updateOutputFileName('protected.pdf'),
      expect: () => [const EncryptPdfState(outputFileName: 'protected.pdf')],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'sets output directory on success',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        const EncryptPdfState(outputDirectory: '/documents/output'),
      ],
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
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

    blocTest<EncryptPdfCubit, EncryptPdfState>(
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
            message: l10n.toolsProtectFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('protect', () {
    const validState = EncryptPdfState(
      inputFilePath: '/documents/input.pdf',
      outputDirectory: '/documents/output',
      outputFileName: 'protected.pdf',
      userPassword: 'user-secret',
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

      when(() => encryptPdfEngine.encrypt(any())).thenAnswer((_) async {
        return File('encrypted.pdf');
      });
    }

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when input file is missing',
      build: buildCubit,
      act: (cubit) => cubit.protect(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectWarningNoFile,
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

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when output directory is missing',
      build: buildCubit,
      seed: () => const EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputFileName: 'protected.pdf',
        userPassword: 'secret',
      ),
      act: (cubit) => cubit.protect(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when output filename is missing',
      build: buildCubit,
      seed: () => const EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        userPassword: 'secret',
      ),
      act: (cubit) => cubit.protect(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when there is no protection to apply',
      build: buildCubit,
      seed: () => const EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'protected.pdf',
      ),
      act: (cubit) => cubit.protect(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectWarningNoProtection,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when user and owner passwords match',
      build: buildCubit,
      seed: () => const EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'protected.pdf',
        userPassword: 'same-secret',
        ownerPassword: 'same-secret',
      ),
      act: (cubit) => cubit.protect(),
      expect: () => [],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectWarningPasswordsMatch,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'submits the correct engine input',
      build: () {
        stubSuccessfulTask();
        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.protect(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        final input =
            verify(() => encryptPdfEngine.encrypt(captureAny())).captured.single
                as EncryptPdfInput;

        expect(input.inputFile.path, '/documents/input.pdf');
        expect(
          input.outputFile.path,
          '/documents/output${Platform.pathSeparator}protected.pdf',
        );
        expect(input.userPassword, 'user-secret');
        expect(input.level, PdfEncryptionLevel.aes256);
        expect(input.permissions, PdfPermissions.all());

        expect(input.ownerPassword, isNotEmpty);
        expect(input.ownerPassword.length, 32);

        verify(
          () => taskManager.submit(
            id: any(named: 'id', that: startsWith('encrypt-pdf-')),
            title: l10n.toolsProtectButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'notifies success after successful encryption',
      build: () {
        stubSuccessfulTask();
        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.protect(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'warns when source PDF is already encrypted',
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

        when(() => encryptPdfEngine.encrypt(any()))
            .thenThrow(PdfPasswordRequired());

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.protect(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectAlreadyEncrypted,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'notifies error for an unexpected failure',
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

        when(() => encryptPdfEngine.encrypt(any()))
            .thenThrow(Exception('encryption failed'));

        return buildCubit();
      },
      seed: () => validState,
      act: (cubit) => cubit.protect(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'notifies error when task submission fails',
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
      act: (cubit) => cubit.protect(),
      expect: () => [
        validState.copyWith(isSubmitting: true),
        validState.copyWith(isSubmitting: false),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsProtectFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );

    blocTest<EncryptPdfCubit, EncryptPdfState>(
      'does nothing when already submitting',
      build: buildCubit,
      seed: () => validState.copyWith(isSubmitting: true),
      act: (cubit) => cubit.protect(),
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
