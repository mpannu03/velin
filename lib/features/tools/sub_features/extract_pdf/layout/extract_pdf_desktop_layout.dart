import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ExtractPdfDesktopLayout extends StatelessWidget {
  const ExtractPdfDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final ExtractPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile = 
        viewModel.inputFilePath != null && 
        viewModel.inputFilePath!.isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsExtractPdf,
      description: l10n.toolsExtractIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // _buildContent(context),
          ToolSectionCard(
            title: l10n.toolsExtractSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsExtractSelectionSectionTitle,
              child: PageSelectionField(
                value: viewModel.pageSelection ?? '',
                fieldKey: const ValueKey('extract-page-selection'),
                width: 260,
                hintText: l10n.toolsExtractSelectionHint,
                onSubmitted: viewModel.onSelectionChanged,
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
              submittingText: l10n.toolsExtractSubmitting,
              canAction: viewModel.canExtract,
              icon: Icons.content_cut_outlined,
              label: l10n.toolsExtractButton,
              hintText: l10n.toolsExtractButtonDisabledHint,
              onAction: viewModel.onExtract,
            ),
          ]
        ],
      ),
    );
  }
}