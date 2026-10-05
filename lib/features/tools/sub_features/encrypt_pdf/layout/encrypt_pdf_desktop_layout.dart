import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class EncryptPdfDesktopLayout extends StatelessWidget {
  const EncryptPdfDesktopLayout({super.key, required this.viewModel});

  final EncryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsProtectPdf,
      description: l10n.toolsProtectIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsProtectSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription:
                  l10n.toolsProtectAlreadyProtectedDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsProtectPasswordSectionTitle,
              child: PasswordEditor(
                userPassword: viewModel.userPassword,
                ownerPassword: viewModel.ownerPassword,
                onUserPasswordChanged: viewModel.onUserPasswordChanged,
                onOwnerPasswordChanged: viewModel.onOwnerPasswordChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsProtectSecuritySectionTitle,
              child: SecurityEditor(
                level: viewModel.level,
                permissions: viewModel.permissions,
                onLevelChanged: viewModel.onLevelChanged,
                onPermissionsChanged: viewModel.onPermissionsChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutputFilePicker(
              fileName: viewModel.outputFileName,
              directoryPath: viewModel.outputDirectory,
              onFileNameChanged: viewModel.onOutputFileNameChanged,
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: AppSpacing.xl),
            ToolActionBar(
              isSubmitting: viewModel.isSubmitting,
              submittingText: l10n.toolsProtectSubmitting,
              canAction: viewModel.canProtect,
              icon: Icons.lock_outline,
              label: l10n.toolsProtectButton,
              hintText: l10n.toolsProtectButtonDisabledHint,
              onAction: viewModel.onProtect,
            ),
          ],
        ],
      ),
    );
  }
}
