import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../widgets/widgets.dart';

class AddWatermarkDesktopLayout extends StatelessWidget {
  const AddWatermarkDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile = viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsWatermark,
      description: l10n.toolsWatermarkIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsWatermarkSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription: l10n.toolsWatermarkSourceDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkTypeSectionTitle,
              child: WatermarkContentEditor(
                type: viewModel.type,
                text: viewModel.text,
                imageFilePath: viewModel.imageFilePath,
                fontName: viewModel.fontName,
                fontSize: viewModel.fontSize,
                colorHex: viewModel.colorHex,
                imageWidthPercent: viewModel.imageWidthPercent,
                onTypeChanged: viewModel.onTypeChanged,
                onTextChanged: viewModel.onTextChanged,
                onFontNameChanged: viewModel.onFontNameChanged,
                onFontSizeChanged: viewModel.onFontSizeChanged,
                onColorHexChanged: viewModel.onColorHexChanged,
                onPickWatermarkImage: viewModel.onPickWatermarkImage,
                onClearWatermarkImage: viewModel.onClearWatermarkImage,
                onImageWidthPercentChanged:
                    viewModel.onImageWidthPercentChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkStyleSectionTitle,
              child: StyleEditor(
                opacity: viewModel.opacity,
                rotation: viewModel.rotation,
                position: viewModel.position,
                xOffset: viewModel.xOffset,
                yOffset: viewModel.yOffset,
                layer: viewModel.layer,
                onOpacityChanged: viewModel.onOpacityChanged,
                onRotationChanged: viewModel.onRotationChanged,
                onPositionChanged: viewModel.onPositionChanged,
                onXOffsetChanged: viewModel.onXOffsetChanged,
                onYOffsetChanged: viewModel.onYOffsetChanged,
                onLayerChanged: viewModel.onLayerChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkPagesSectionTitle,
              child: PageScopeEditor(
                scope: viewModel.scope,
                selection: viewModel.selection,
                onScopeChanged: viewModel.onScopeChanged,
                onSelectionChanged: viewModel.onSelectionChanged,
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
              submittingText: l10n.toolsWatermarkSubmitting,
              canAction: viewModel.canApplyWatermark,
              icon: Icons.water_outlined,
              label: l10n.toolsWatermarkButton,
              hintText: l10n.toolsWatermarkButtonDisabledHint,
              onAction: viewModel.onApplyWatermark,
            ),
          ],
        ],
      ),
    );
  }
}
