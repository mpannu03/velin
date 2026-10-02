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

  static const _maxContentWidth = 1000.0;

  final MergePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ToolScaffold(
      title: l10n.toolsMergePdf,
      description: l10n.toolsMergeIntro,
      onBack: context.pop,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildContent(context),
                const SizedBox(height: AppSpacing.xl),
                _MergeActionBar(viewModel: viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final inputPicker = MultiFilePicker(
      filePaths: [
        for (final input in viewModel.inputs) input.filePath,
      ],
      pageSelections: [
        for (final input in viewModel.inputs) input.pageSelection,
      ],
      showPageSelection: true,
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

class _MergeActionBar extends StatelessWidget {
  const _MergeActionBar({required this.viewModel});

  final MergePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (viewModel.isSubmitting) {
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(l10n.toolsMergeSubmitting),
        ),
      );
    }

    final button = viewModel.canMerge
        ? FilledButton.icon(
            onPressed: viewModel.onMerge,
            icon: const Icon(Icons.merge_type, size: 18),
            label: Text(l10n.toolsMergeButton),
          )
        : OutlinedButton.icon(
            onPressed: viewModel.onMerge,
            icon: const Icon(Icons.merge_type, size: 18),
            label: Text(l10n.toolsMergeButton),
          );

    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(
        message: viewModel.canMerge ? '' : l10n.toolsMergeButtonDisabledHint,
        child: button,
      ),
    );
  }
}
