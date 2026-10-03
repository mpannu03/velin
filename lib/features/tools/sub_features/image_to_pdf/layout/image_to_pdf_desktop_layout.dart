import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
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

class _HelperText extends StatelessWidget {
  const _HelperText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        _PageSizeSelector(viewModel: viewModel),
        const SizedBox(height: AppSpacing.lg),
        _OrientationSelector(viewModel: viewModel),
        const SizedBox(height: AppSpacing.lg),
        _FitSelector(viewModel: viewModel),
      ],
    );
  }
}

class _PageSizeSelector extends StatelessWidget {
  const _PageSizeSelector({required this.viewModel});

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfPageSize>(
          key: const ValueKey('image-to-pdf-page-size'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: ImageToPdfPageSize.auto,
              icon: const Icon(
                Icons.photo_size_select_actual_outlined,
                size: 18,
              ),
              label: Text(l10n.toolsImageToPdfPageSizeAuto),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.a4,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfPageSizeA4),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.letter,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfPageSizeLetter),
            ),
          ],
          selected: {viewModel.pageSize},
          onSelectionChanged: (selection) =>
              viewModel.onPageSizeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsImageToPdfPageSizeHelper),
      ],
    );
  }
}

class _OrientationSelector extends StatelessWidget {
  const _OrientationSelector({required this.viewModel});

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfOrientation>(
          key: const ValueKey('image-to-pdf-orientation'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: ImageToPdfOrientation.auto,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfOrientationAuto),
            ),
            ButtonSegment(
              value: ImageToPdfOrientation.portrait,
              icon: const Icon(
                Icons.stay_current_portrait_outlined,
                size: 18,
              ),
              label: Text(l10n.toolsImageToPdfOrientationPortrait),
            ),
            ButtonSegment(
              value: ImageToPdfOrientation.landscape,
              icon: const Icon(
                Icons.stay_current_landscape_outlined,
                size: 18,
              ),
              label: Text(l10n.toolsImageToPdfOrientationLandscape),
            ),
          ],
          selected: {viewModel.orientation},
          onSelectionChanged: (selection) =>
              viewModel.onOrientationChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsImageToPdfOrientationHelper),
      ],
    );
  }
}

class _FitSelector extends StatelessWidget {
  const _FitSelector({required this.viewModel});

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfFit>(
          key: const ValueKey('image-to-pdf-fit'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: ImageToPdfFit.contain,
              icon: const Icon(Icons.fit_screen_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitContain),
            ),
            ButtonSegment(
              value: ImageToPdfFit.cover,
              icon: const Icon(Icons.crop_free_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitCover),
            ),
            ButtonSegment(
              value: ImageToPdfFit.stretch,
              icon: const Icon(Icons.open_in_full_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitStretch),
            ),
          ],
          selected: {viewModel.fit},
          onSelectionChanged: (selection) =>
              viewModel.onFitChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsImageToPdfFitHelper),
      ],
    );
  }
}
