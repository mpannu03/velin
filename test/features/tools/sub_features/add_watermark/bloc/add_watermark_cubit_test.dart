import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task_manager.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockAddWatermarkEngine extends Mock implements AddWatermarkEngine {}

class MockTaskManager extends Mock implements TaskManager {}

class MockAppEffectController extends Mock implements AppEffectController {}

class FakeAddWatermarkInput extends Fake implements AddWatermarkInput {}

void main() {
  late MockDocumentFilePicker filePicker;
  late MockAddWatermarkEngine engine;
  late MockTaskManager taskManager;
  late MockAppEffectController effectController;
  late AppLocalizations l10n;

  setUpAll(() {
    registerFallbackValue(FakeAddWatermarkInput());
    registerFallbackValue(NotificationType.error);
  });

  setUp(() {
    filePicker = MockDocumentFilePicker();
    engine = MockAddWatermarkEngine();
    taskManager = MockTaskManager();
    effectController = MockAppEffectController();
    l10n = lookupAppLocalizations(const Locale('en'));

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
  });

  AddWatermarkCubit buildCubit({
    AddWatermarkState state = const AddWatermarkState(),
  }) {
    return AddWatermarkCubit(
      l10n: l10n,
      filePicker: filePicker,
      addWatermarkEngine: engine,
      taskManager: taskManager,
      appEffectController: effectController,
    )..emit(state);
  }

  group('initial state', () {
    test('uses default state', () {
      final cubit = AddWatermarkCubit(
        l10n: l10n,
        filePicker: filePicker,
        addWatermarkEngine: engine,
        taskManager: taskManager,
        appEffectController: effectController,
      );

      expect(cubit.state, const AddWatermarkState());

      cubit.close();
    });
  });

  group('pickFile', () {
    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updates input and default output values on success',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
            .thenAnswer((_) async => const Success('/documents/report.pdf'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        isA<AddWatermarkState>()
            .having(
              (state) => state.inputFilePath,
              'inputFilePath',
              '/documents/report.pdf',
            )
            .having(
              (state) => state.outputDirectory,
              'outputDirectory',
              '/documents/',
            )
            .having(
              (state) => state.outputFileName,
              'outputFileName',
              'report_watermarked.pdf',
            ),
      ],
      verify: (_) {
        verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'does nothing when picker is cancelled',
      build: () {
        when(() => filePicker.pickFile(allowedExtensions: ['pdf'])).thenAnswer(
          (_) async =>
              Failure<String>(const DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verifyNever(
          () => effectController.notifyUser(
            message: any(named: 'message'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows an error when picker fails',
      build: () {
        when(
          () => filePicker.pickFile(allowedExtensions: ['pdf']),
        ).thenAnswer((_) async => Failure<String>(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('pickWatermarkImage', () {
    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updates image path on success',
      build: () {
        when(
          () => filePicker.pickFile(
            allowedExtensions: AddWatermarkToolInput.supportedImageExtensions,
          ),
        ).thenAnswer((_) async => const Success('/images/stamp.png'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickWatermarkImage(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.imageFilePath,
          'imageFilePath',
          '/images/stamp.png',
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'is silent when image picker is cancelled',
      build: () {
        when(
          () => filePicker.pickFile(
            allowedExtensions: AddWatermarkToolInput.supportedImageExtensions,
          ),
        ).thenAnswer(
          (_) async =>
              Failure<String>(const DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickWatermarkImage(),
      expect: () => <AddWatermarkState>[],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows an error when image picker fails',
      build: () {
        when(
          () => filePicker.pickFile(
            allowedExtensions: AddWatermarkToolInput.supportedImageExtensions,
          ),
        ).thenAnswer((_) async => Failure<String>(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickWatermarkImage(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('state mutations', () {
    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'clearWatermarkImage clears image',
      build: () => buildCubit(
        state: const AddWatermarkState(imageFilePath: '/images/stamp.png'),
      ),
      act: (cubit) => cubit.clearWatermarkImage(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.imageFilePath,
          'imageFilePath',
          isNull,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeType updates type',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeType(WatermarkType.image),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.type,
          'type',
          WatermarkType.image,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeType does nothing when unchanged',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeType(WatermarkType.text),
      expect: () => <AddWatermarkState>[],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updateText updates text',
      build: () => buildCubit(),
      act: (cubit) => cubit.updateText('DRAFT'),
      expect: () => [
        isA<AddWatermarkState>().having((state) => state.text, 'text', 'DRAFT'),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeFontName updates font',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeFontName('Helvetica-Bold'),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.fontName,
          'fontName',
          'Helvetica-Bold',
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeFontSize clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeFontSize(500),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.fontSize,
          'fontSize',
          AddWatermarkToolInput.maxFontSize,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeOpacity clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeOpacity(-1),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.opacity,
          'opacity',
          AddWatermarkToolInput.minOpacity,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeRotation clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeRotation(500),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.rotation,
          'rotation',
          AddWatermarkToolInput.maxRotation,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changePosition updates position',
      build: () => buildCubit(),
      act: (cubit) => cubit.changePosition(WatermarkPosition.topLeft),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.position,
          'position',
          WatermarkPosition.topLeft,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeXOffset clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeXOffset(500),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.xOffset,
          'xOffset',
          AddWatermarkToolInput.maxOffset,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeYOffset clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeYOffset(-500),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.yOffset,
          'yOffset',
          AddWatermarkToolInput.minOffset,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeImageWidthPercent clamps value',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeImageWidthPercent(500),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.imageWidthPercent,
          'imageWidthPercent',
          AddWatermarkToolInput.maxImageWidthPercent,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeLayer updates layer',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeLayer(WatermarkLayer.background),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.layer,
          'layer',
          WatermarkLayer.background,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'changeScope updates scope',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeScope(WatermarkPageScope.selectedPages),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.scope,
          'scope',
          WatermarkPageScope.selectedPages,
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updateSelection updates selection',
      build: () => buildCubit(),
      act: (cubit) => cubit.updateSelection('1-3,7'),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.selection,
          'selection',
          '1-3,7',
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updateOutputFileName normalizes filename',
      build: () => buildCubit(),
      act: (cubit) => cubit.updateOutputFileName('output'),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.outputFileName,
          'outputFileName',
          'output.pdf',
        ),
      ],
    );
  });

  group('changeColorHex', () {
    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'normalizes a valid color',
      build: () => buildCubit(),
      act: (cubit) => cubit.changeColorHex('  #ff00aa  '),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.colorHex,
          'colorHex',
          '#FF00AA',
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'rejects an invalid color and shows warning',
      build: () =>
          buildCubit(state: const AddWatermarkState(colorHex: '#808080')),
      act: (cubit) => cubit.changeColorHex('not-a-color'),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningInvalidColor,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'does nothing when normalized color is unchanged',
      build: () =>
          buildCubit(state: const AddWatermarkState(colorHex: '#FF00AA')),
      act: (cubit) => cubit.changeColorHex(' #ff00aa '),
      expect: () => <AddWatermarkState>[],
    );
  });

  group('pickOutputDirectory', () {
    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'updates output directory on success',
      build: () {
        when(() => filePicker.pickDirectory())
            .thenAnswer((_) async => const Success('/documents/output'));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.outputDirectory,
          'outputDirectory',
          '/documents/output',
        ),
      ],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'is silent when directory picker is cancelled',
      build: () {
        when(() => filePicker.pickDirectory()).thenAnswer(
          (_) async =>
              Failure<String>(const DocumentFilePickerError('cancelled')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <AddWatermarkState>[],
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows an error when directory picker fails',
      build: () {
        when(
          () => filePicker.pickDirectory(),
        ).thenAnswer((_) async => Failure<String>(Exception('picker failed')));

        return buildCubit();
      },
      act: (cubit) => cubit.pickOutputDirectory(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });

  group('applyWatermark', () {
    test('does nothing while already submitting', () async {
      final cubit = buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'output.pdf',
          isSubmitting: true,
        ),
      );

      await cubit.applyWatermark();

      verifyNever(
        () => taskManager.submit(
          id: any(named: 'id'),
          title: any(named: 'title'),
          operation: any(named: 'operation'),
        ),
      );

      await cubit.close();
    });

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when input file is missing',
      build: () => buildCubit(),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningNoFile,
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

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when watermark content is missing',
      build: () => buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          text: '',
        ),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningNoText,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when color is invalid',
      build: () => buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          colorHex: 'invalid',
        ),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningInvalidColor,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when selected scope has no selection',
      build: () => buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          scope: WatermarkPageScope.selectedPages,
          selection: '',
        ),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningNoSelection,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when output directory is missing',
      build: () => buildCubit(
        state: const AddWatermarkState(inputFilePath: '/documents/input.pdf'),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningNoFolder,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when output filename is missing',
      build: () => buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
        ),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkWarningNoFileName,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning for malformed page selection',
      build: () => buildCubit(
        state: const AddWatermarkState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents',
          outputFileName: 'output.pdf',
          scope: WatermarkPageScope.selectedPages,
          selection: 'abc',
        ),
      ),
      act: (cubit) => cubit.applyWatermark(),
      expect: () => <AddWatermarkState>[],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkSelectionInvalid,
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

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'submits task and shows success',
      build: () {
        when(() => engine.addWatermark(input: any(named: 'input')))
            .thenAnswer((_) async => File('/documents/output.pdf'));

        return buildCubit(
          state: const AddWatermarkState(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents',
            outputFileName: 'output.pdf',
          ),
        );
      },
      act: (cubit) => cubit.applyWatermark(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
      verify: (_) {
        verify(
          () => taskManager.submit(
            id: any(named: 'id', that: startsWith('add-watermark-')),
            title: l10n.toolsWatermarkButton,
            operation: any(named: 'operation'),
          ),
        ).called(1);

        verify(() => engine.addWatermark(input: any(named: 'input'))).called(1);

        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkSuccess,
            type: NotificationType.success,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'passes selected page scope to the engine',
      build: () {
        when(() => engine.addWatermark(input: any(named: 'input')))
            .thenAnswer((_) async => File('/documents/output.pdf'));

        return buildCubit(
          state: const AddWatermarkState(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents',
            outputFileName: 'output.pdf',
            scope: WatermarkPageScope.selectedPages,
            selection: '1-3',
          ),
        );
      },
      act: (cubit) => cubit.applyWatermark(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
      verify: (_) {
        final captured =
            verify(() => engine.addWatermark(input: captureAny(named: 'input')))
                    .captured
                    .single
                as AddWatermarkInput;

        expect(captured.file.path, '/documents/input.pdf');
        expect(
          captured.outputFile.path,
          '/documents${Platform.pathSeparator}output.pdf',
        );
        expect(captured.text, 'CONFIDENTIAL');
        expect(captured.colorHex, '808080');
        expect(captured.selection, isNotNull);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows warning when engine throws ArgumentError',
      build: () {
        when(() => engine.addWatermark(input: any(named: 'input')))
            .thenThrow(ArgumentError('invalid watermark'));

        return buildCubit(
          state: const AddWatermarkState(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents',
            outputFileName: 'output.pdf',
          ),
        );
      },
      act: (cubit) => cubit.applyWatermark(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkFailed,
            type: NotificationType.warning,
          ),
        ).called(1);
      },
    );

    blocTest<AddWatermarkCubit, AddWatermarkState>(
      'shows error when engine throws unexpected error',
      build: () {
        when(() => engine.addWatermark(input: any(named: 'input')))
            .thenThrow(StateError('unexpected failure'));

        return buildCubit(
          state: const AddWatermarkState(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents',
            outputFileName: 'output.pdf',
          ),
        );
      },
      act: (cubit) => cubit.applyWatermark(),
      expect: () => [
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<AddWatermarkState>().having(
          (state) => state.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
      verify: (_) {
        verify(
          () => effectController.notifyUser(
            message: l10n.toolsWatermarkFailed,
            type: NotificationType.error,
          ),
        ).called(1);
      },
    );
  });
}
