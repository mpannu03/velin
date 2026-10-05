import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class DecryptPdfDesktopLayout extends StatelessWidget {
  const DecryptPdfDesktopLayout({super.key, required this.viewModel});

  final DecryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsUnlockPdf,
      description: l10n.toolsUnlockIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsUnlockSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription:
                  l10n.toolsUnlockAlreadyProtectedDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsUnlockPasswordSectionTitle,
              child: PasswordField(
                fieldKey: const ValueKey('decrypt-password'),
                value: viewModel.password,
                labelText: l10n.toolsUnlockPasswordLabel,
                helperText: l10n.toolsUnlockPasswordHelper,
                onChanged: viewModel.onPasswordChanged,
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
              submittingText: l10n.toolsUnlockSubmitting,
              canAction: viewModel.canDecrypt,
              icon: Icons.lock_open_outlined,
              label: l10n.toolsUnlockButton,
              hintText: l10n.toolsUnlockButtonDisabledHint,
              onAction: viewModel.onUnlock,
            ),
          ],
        ],
      ),
    );
  }
}
