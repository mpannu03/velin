import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

class MergePdfDesktopLayout extends StatelessWidget {
  const MergePdfDesktopLayout({
    required this.viewModel,
    super.key,
  });

  final MergePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Merge PDF',
      onBack: context.pop,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultiFilePicker(
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
            ),
            const SizedBox(height: 24),
            OutputFilePicker(
              fileName: viewModel.outputFileName,
              directoryPath: viewModel.outputDirectory,
              onFileNameChanged: viewModel.onOutputFileNameChanged,
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: viewModel.isSubmitting
                    ? null
                    : viewModel.onMerge,
                icon: const Icon(Icons.merge_type),
                label: Text(
                  viewModel.isSubmitting ? 'Merging...' : 'Merge PDF',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
