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
    final hasInputFile = viewModel.inputFilePath != null &&
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
              child: _QualityEditor(viewModel: viewModel),
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

class _QualityEditor extends StatelessWidget {
  const _QualityEditor({required this.viewModel});

  final CompressPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsCompressQualityLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Slider(
                key: const ValueKey('compress-pdf-quality'),
                value: viewModel.quality.toDouble(),
                min: CompressPdfToolInput.minQuality.toDouble(),
                max: CompressPdfToolInput.maxQuality.toDouble(),
                divisions:
                    CompressPdfToolInput.maxQuality -
                        CompressPdfToolInput.minQuality,
                label: '${viewModel.quality}',
                onChanged: (value) =>
                    viewModel.onQualityChanged(value.round()),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${viewModel.quality}',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.toolsCompressQualityHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}