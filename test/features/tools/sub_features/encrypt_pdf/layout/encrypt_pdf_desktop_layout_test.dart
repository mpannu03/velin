import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  EncryptPdfViewModel createViewModel({
    String? inputFilePath,
    String? outputFileName,
    String? outputDirectory,
    String userPassword = '',
    String ownerPassword = '',
    EncryptPdfEncryptionLevel level = EncryptPdfEncryptionLevel.aes256,
    EncryptPdfPermissionPreset permissions = EncryptPdfPermissionPreset.all,
    bool isSubmitting = false,
    bool canProtect = false,
    VoidCallback? onBack,
    VoidCallback? onPickFile,
    ValueChanged<String>? onUserPasswordChanged,
    ValueChanged<String>? onOwnerPasswordChanged,
    ValueChanged<EncryptPdfEncryptionLevel>? onLevelChanged,
    ValueChanged<EncryptPdfPermissionPreset>? onPermissionsChanged,
    ValueChanged<String>? onOutputFileNameChanged,
    VoidCallback? onChooseOutputFolder,
    VoidCallback? onProtect,
  }) {
    return EncryptPdfViewModel(
      inputFilePath: inputFilePath,
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
      userPassword: userPassword,
      ownerPassword: ownerPassword,
      level: level,
      permissions: permissions,
      isSubmitting: isSubmitting,
      canProtect: canProtect,
      onBack: onBack ?? () {},
      onPickFile: onPickFile ?? () {},
      onUserPasswordChanged: onUserPasswordChanged ?? (_) {},
      onOwnerPasswordChanged: onOwnerPasswordChanged ?? (_) {},
      onLevelChanged: onLevelChanged ?? (_) {},
      onPermissionsChanged: onPermissionsChanged ?? (_) {},
      onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
      onChooseOutputFolder: onChooseOutputFolder ?? () {},
      onProtect: onProtect ?? () {},
    );
  }

  group('EncryptPdfDesktopLayout', () {
    testWidgets('renders source picker without an input file', (tester) async {
      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(viewModel: createViewModel()),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PasswordEditor), findsNothing);
      expect(find.byType(SecurityEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('hides dependent controls for empty input path', (
      tester,
    ) async {
      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(viewModel: createViewModel(inputFilePath: '')),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PasswordEditor), findsNothing);
      expect(find.byType(SecurityEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('hides dependent controls for whitespace-only input path', (
      tester,
    ) async {
      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(inputFilePath: '   '),
        ),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PasswordEditor), findsNothing);
      expect(find.byType(SecurityEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders all controls when an input file is selected', (
      tester,
    ) async {
      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            outputFileName: 'protected.pdf',
            outputDirectory: '/documents',
            canProtect: true,
          ),
        ),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PasswordEditor), findsOneWidget);
      expect(find.byType(SecurityEditor), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('forwards file picker callback', (tester) async {
      var called = false;

      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(onPickFile: () => called = true),
        ),
      );

      final picker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );

      picker.onPickFile();

      expect(called, isTrue);
    });

    testWidgets('forwards password callbacks', (tester) async {
      String? userPassword;
      String? ownerPassword;

      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            onUserPasswordChanged: (value) => userPassword = value,
            onOwnerPasswordChanged: (value) => ownerPassword = value,
          ),
        ),
      );

      final editor = tester.widget<PasswordEditor>(find.byType(PasswordEditor));

      editor.onUserPasswordChanged('user-secret');
      editor.onOwnerPasswordChanged('owner-secret');

      expect(userPassword, 'user-secret');
      expect(ownerPassword, 'owner-secret');
    });

    testWidgets('forwards security callbacks', (tester) async {
      EncryptPdfEncryptionLevel? level;
      EncryptPdfPermissionPreset? permissions;

      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            onLevelChanged: (value) => level = value,
            onPermissionsChanged: (value) => permissions = value,
          ),
        ),
      );

      final editor = tester.widget<SecurityEditor>(find.byType(SecurityEditor));

      editor.onLevelChanged(EncryptPdfEncryptionLevel.rc4);
      editor.onPermissionsChanged(EncryptPdfPermissionPreset.none);

      expect(level, EncryptPdfEncryptionLevel.rc4);
      expect(permissions, EncryptPdfPermissionPreset.none);
    });

    testWidgets('forwards output callbacks', (tester) async {
      String? fileName;
      var folderCalled = false;

      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            onOutputFileNameChanged: (value) => fileName = value,
            onChooseOutputFolder: () => folderCalled = true,
          ),
        ),
      );

      final picker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      picker.onFileNameChanged?.call('protected.pdf');
      picker.onChooseFolder();

      expect(fileName, 'protected.pdf');
      expect(folderCalled, isTrue);
    });

    testWidgets('forwards protect callback', (tester) async {
      var called = false;

      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            onProtect: () => called = true,
          ),
        ),
      );

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      actionBar.onAction();

      expect(called, isTrue);
    });

    testWidgets('passes submitting and enabled state to action bar', (
      tester,
    ) async {
      await pumpApp(
        tester,
        EncryptPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/input.pdf',
            isSubmitting: true,
            canProtect: false,
          ),
        ),
      );

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
    });
  });
}
