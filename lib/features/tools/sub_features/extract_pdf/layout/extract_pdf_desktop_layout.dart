import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ExtractPdfDesktopLayout extends StatelessWidget {
  const ExtractPdfDesktopLayout({
    super.key,
    required this.viewModel,
  });

  static const _maxContentWidth = 1000.0;

  final ExtractPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ToolScaffold(
      title: l10n.toolsExtractPdf,
      description: l10n.toolsExtractIntro,
      onBack: viewModel.onBack,
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
                ToolActionBar(
                  isSubmitting: viewModel.isSubmitting,
                  submittingText: l10n.toolsExtractSubmitting,
                  canAction: viewModel.canExtract,
                  icon: Icons.content_cut_outlined,
                  label: l10n.toolsExtractButton,
                  hintText: l10n.toolsExtractButtonDisabledHint,
                  onAction: viewModel.onExtract,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: l10n.toolsExtractSourceSectionTitle,
          child: SingleFilePicker(
            filePath: viewModel.inputFilePath,
            onPickFile: viewModel.onPickFile,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: l10n.toolsExtractSelectionSectionTitle,
          child: SizedBox(
            width: 260,
            child: TextField(
              key: const ValueKey('extract-page-selection'),
              controller: TextEditingController(
                text: viewModel.pageSelection ?? '',
              ),
              onSubmitted: viewModel.onSelectionChanged,
              decoration: InputDecoration(
                labelText: l10n.toolsPagesLabel,
                hintText: l10n.toolsExtractSelectionHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutputFilePicker(
          fileName: viewModel.outputFileName,
          directoryPath: viewModel.outputDirectory,
          onFileNameChanged: viewModel.onOutputFileNameChanged,
          onChooseFolder: viewModel.onChooseOutputFolder,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}