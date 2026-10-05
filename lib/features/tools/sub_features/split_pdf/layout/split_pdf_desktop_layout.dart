import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class SplitPdfDesktopLayout extends StatelessWidget {
  const SplitPdfDesktopLayout({required this.viewModel, super.key});

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null && viewModel.inputFilePath!.isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsSplitPdf,
      description: l10n.toolsSplitIntro,
      onBack: context.pop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsSplitSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsSplitModeSectionTitle,
              child: SplitModeEditor(
                mode: viewModel.mode,
                onModeChanged: viewModel.onModeChanged,
                pageCount: viewModel.pageCount,
                onPageCountChanged: viewModel.onPageCountChanged,
                selections: viewModel.selections,
                onSelectionChanged: viewModel.onSelectionChanged,
                onAddSelection: viewModel.onAddSelection,
                onRemoveSelection: viewModel.onRemoveSelection,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutputFilePicker(
              fileName: '',
              directoryPath: viewModel.outputDirectory,
              showFileName: false,
              onFileNameChanged: (_) {},
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: AppSpacing.xl),
            ToolActionBar(
              isSubmitting: viewModel.isSubmitting,
              submittingText: l10n.toolsSplitSubmitting,
              canAction: viewModel.canSplit,
              icon: Icons.call_split,
              label: l10n.toolsSplitButton,
              hintText: l10n.toolsSplitButtonDisabledHint,
              onAction: viewModel.onSplit,
            ),
          ],
        ],
      ),
    );
  }
}
