import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class MergePdfDesktopLayout extends StatelessWidget {
  const MergePdfDesktopLayout({
    required this.viewModel,
    super.key,
  });

  final MergePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ToolScaffold(
      title: l10n.toolsMergePdf,
      description: l10n.toolsMergeIntro,
      onBack: context.pop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildContent(context),
          const SizedBox(height: AppSpacing.xl),
          ToolActionBar(
            isSubmitting: viewModel.isSubmitting, 
            submittingText: l10n.toolsMergeSubmitting, 
            canAction: viewModel.canMerge, 
            icon: Icons.merge_type, 
            label: l10n.toolsMergeButton, 
            hintText: l10n.toolsMergeButtonDisabledHint, 
            onAction: () {  },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;

    final inputPicker = MultiFilePicker(
      filePaths: [
        for (final input in viewModel.inputs) input.filePath,
      ],
      pageSelections: [
        for (final input in viewModel.inputs) input.pageSelection,
      ],
      showPageSelection: true,
      emptyStateDescription: l10n.toolsMergeNoFilesDescription,
      onAddFiles: viewModel.onAddFiles,
      onRemoveFile: viewModel.onRemoveFile,
      onReorderItem: viewModel.onReorder,
      onPageSelectionChanged: viewModel.onPageSelectionChanged,
    );

    final outputPicker = OutputFilePicker(
      fileName: viewModel.outputFileName,
      directoryPath: viewModel.outputDirectory,
      onFileNameChanged: viewModel.onOutputFileNameChanged,
      onChooseFolder: viewModel.onChooseOutputFolder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        inputPicker,
        const SizedBox(height: AppSpacing.lg),
        outputPicker,
      ],
    );
  }
}
