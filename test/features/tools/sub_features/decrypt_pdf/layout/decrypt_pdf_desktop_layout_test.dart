import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('DecryptPdfDesktopLayout', () {
    testWidgets('always renders the source file picker', (tester) async {
      await pumpApp(tester, DecryptPdfDesktopLayout(viewModel: _viewModel()));

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(
        find.text(
          tester
              .element(find.byType(DecryptPdfDesktopLayout))
              .l10n
              .toolsUnlockSourceSectionTitle,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'hides password, output, and action controls when input is missing',
      (tester) async {
        await pumpApp(tester, DecryptPdfDesktopLayout(viewModel: _viewModel()));

        expect(find.byType(PasswordField), findsNothing);
        expect(find.byType(OutputFilePicker), findsNothing);
        expect(find.byType(ToolActionBar), findsNothing);
      },
    );

    testWidgets('treats whitespace-only input as missing', (tester) async {
      await pumpApp(
        tester,
        DecryptPdfDesktopLayout(viewModel: _viewModel(inputFilePath: '   ')),
      );

      expect(find.byType(PasswordField), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets(
      'renders password, output, and action controls when input exists',
      (tester) async {
        await pumpApp(
          tester,
          DecryptPdfDesktopLayout(
            viewModel: _viewModel(
              inputFilePath: '/documents/protected.pdf',
              password: 'secret',
              outputFileName: 'unlocked.pdf',
              outputDirectory: '/documents',
              isSubmitting: false,
              canDecrypt: true,
            ),
          ),
        );

        expect(find.byType(SingleFilePicker), findsOneWidget);
        expect(find.byType(PasswordField), findsOneWidget);
        expect(find.byType(OutputFilePicker), findsOneWidget);
        expect(find.byType(ToolActionBar), findsOneWidget);
      },
    );

    testWidgets('forwards ViewModel values and callbacks', (tester) async {
      var pickedFile = false;
      var passwordChanged = '';
      var outputFileNameChanged = '';
      var outputFolderChosen = false;
      var decryptPressed = false;
      var backPressed = false;

      final viewModel = _viewModel(
        inputFilePath: '/documents/protected.pdf',
        password: 'secret',
        outputFileName: 'unlocked.pdf',
        outputDirectory: '/documents',
        isSubmitting: false,
        canDecrypt: true,
        onPickFile: () async {
          pickedFile = true;
        },
        onPasswordChanged: (value) {
          passwordChanged = value;
        },
        onOutputFileNameChanged: (value) {
          outputFileNameChanged = value ?? '';
        },
        onChooseOutputFolder: () async {
          outputFolderChosen = true;
        },
        onUnlock: () async {
          decryptPressed = true;
        },
        onBack: () {
          backPressed = true;
        },
      );

      await pumpApp(tester, DecryptPdfDesktopLayout(viewModel: viewModel));

      final sourcePicker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );
      sourcePicker.onPickFile();
      expect(pickedFile, isTrue);

      final passwordField = tester.widget<PasswordField>(
        find.byType(PasswordField),
      );
      passwordField.onChanged('new-password');
      expect(passwordChanged, 'new-password');

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      outputPicker.onFileNameChanged?.call('output.pdf');
      expect(outputFileNameChanged, 'output.pdf');

      outputPicker.onChooseFolder();
      expect(outputFolderChosen, isTrue);

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );
      actionBar.onAction();
      expect(decryptPressed, isTrue);

      final scaffold = tester.widget<ToolScaffold>(find.byType(ToolScaffold));
      scaffold.onBack?.call();
      expect(backPressed, isTrue);
    });
  });
}

DecryptPdfViewModel _viewModel({
  String? inputFilePath,
  String? password,
  String? outputFileName,
  String? outputDirectory,
  bool isSubmitting = false,
  bool canDecrypt = false,
  Future<void> Function()? onPickFile,
  ValueChanged<String>? onPasswordChanged,
  ValueChanged<String?>? onOutputFileNameChanged,
  Future<void> Function()? onChooseOutputFolder,
  Future<void> Function()? onUnlock,
  VoidCallback? onBack,
}) {
  return DecryptPdfViewModel(
    inputFilePath: inputFilePath,
    password: password ?? '',
    outputFileName: outputFileName,
    outputDirectory: outputDirectory,
    isSubmitting: isSubmitting,
    canDecrypt: canDecrypt,
    onPickFile: onPickFile ?? () async {},
    onPasswordChanged: onPasswordChanged ?? (_) {},
    onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
    onChooseOutputFolder: onChooseOutputFolder ?? () async {},
    onUnlock: onUnlock ?? () async {},
    onBack: onBack ?? () {},
  );
}
