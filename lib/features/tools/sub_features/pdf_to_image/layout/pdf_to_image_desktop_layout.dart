import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

class PdfToImageDesktopLayout extends StatelessWidget {
  const PdfToImageDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile = viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsPdfToImage,
      description: l10n.toolsPdfToImageIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsPdfToImageSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageFormatSectionTitle,
              child: FormatSelector(
                format: viewModel.format,
                onFormatChanged: viewModel.onFormatChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageColorSectionTitle,
              child: ColorModeSelector(
                colorMode: viewModel.colorMode,
                onColorModeChanged: viewModel.onColorModeChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageResolutionSectionTitle,
              child: ResolutionEditor(
                quality: viewModel.quality,
                onQualityChanged: viewModel.onQualityChanged,
                supportsQuality: viewModel.supportsQuality,
                dpi: viewModel.dpi,
                onDpiChanged: viewModel.onDpiChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImagePagesSectionTitle,
              child: PageScopeEditor<PdfToImagePageScope>(
                allPagesScope: PdfToImagePageScope.allPages,
                selectedPagesScope: PdfToImagePageScope.selectedPages,
                scope: viewModel.scope,
                requiresSelection: viewModel.scope.requiresSelection,
                allPagesLabel: l10n.toolsPdfToImageScopeAll,
                selectedPagesLabel: l10n.toolsPdfToImageScopeSelected,
                onScopeChanged: viewModel.onScopeChanged,
                selection: viewModel.selection,
                selectionFieldKey:
                    const ValueKey('pdf-to-image-page-selection'),
                selectionHintText: l10n.toolsPdfToImageSelectionHint,
                selectionHelperText: l10n.toolsPdfToImageSelectionHelper,
                onSelectionChanged: viewModel.onSelectionChanged,
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
              submittingText: l10n.toolsPdfToImageSubmitting,
              canAction: viewModel.canConvert,
              icon: Icons.image_outlined,
              label: l10n.toolsPdfToImageButton,
              hintText: l10n.toolsPdfToImageButtonDisabledHint,
              onAction: viewModel.onConvert,
            ),
          ],
        ],
      ),
    );
  }
}
