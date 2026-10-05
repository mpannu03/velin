import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ImageToPdfDesktopLayout extends StatelessWidget {
  const ImageToPdfDesktopLayout({
    required this.viewModel,
    super.key,
  });

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasImages = viewModel.inputs.isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsImageToPdf,
      description: l10n.toolsImageToPdfIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImageFilePicker(
            filePaths: [
              for (final input in viewModel.inputs) input.filePath,
            ],
            viewMode: viewModel.viewMode,
            emptyStateDescription: l10n.toolsImageToPdfNoImagesDescription,
            onAddFiles: viewModel.onAddImages,
            onRemoveFile: viewModel.onRemoveImage,
            onReorderItem: viewModel.onReorder,
            onViewModeChanged: viewModel.onViewModeChanged,
          ),
          if (hasImages) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsImageToPdfPageSetupSectionTitle,
              child: _PageSetupEditor(viewModel: viewModel),
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
              submittingText: l10n.toolsImageToPdfSubmitting,
              canAction: viewModel.canConvert,
              icon: Icons.picture_as_pdf_outlined,
              label: l10n.toolsImageToPdfButton,
              hintText: l10n.toolsImageToPdfButtonDisabledHint,
              onAction: viewModel.onConvert,
            ),
          ],
        ],
      ),
    );
  }
}

class _PageSetupEditor extends StatelessWidget {
  const _PageSetupEditor({required this.viewModel});

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageSizeSelector(
          pageSize: viewModel.pageSize,
          onPageSizeChanged: viewModel.onPageSizeChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        OrientationSelector(
          orientation: viewModel.orientation, 
          onOrientationChanged: viewModel.onOrientationChanged
        ),
        const SizedBox(height: AppSpacing.lg),
        FitSelector(
          fit: viewModel.fit, 
          onFitChanged: viewModel.onFitChanged
        ),
      ],
    );
  }
}
