import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class CompressPdfDesktopLayout extends StatelessWidget {
  const CompressPdfDesktopLayout({super.key, required this.viewModel});

  final CompressPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsCompressPdf,
      description: l10n.toolsCompressIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsCompressSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription: l10n.toolsCompressSourceDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsCompressQualitySectionTitle,
              child: QualityEditor(
                quality: viewModel.quality,
                onQualityChanged: viewModel.onQualityChanged,
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
              submittingText: l10n.toolsCompressSubmitting,
              canAction: viewModel.canCompress,
              icon: Icons.compress_outlined,
              label: l10n.toolsCompressButton,
              hintText: l10n.toolsCompressButtonDisabledHint,
              onAction: viewModel.onCompress,
            ),
          ],
        ],
      ),
    );
  }
}
