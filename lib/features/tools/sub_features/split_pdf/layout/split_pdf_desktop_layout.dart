import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class SplitPdfDesktopLayout extends StatelessWidget {
  const SplitPdfDesktopLayout({
    required this.viewModel,
    super.key,
  });

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ToolScaffold(
      title: l10n.toolsSplitPdf,
      description: l10n.toolsSplitIntro,
      onBack: context.pop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildContent(context),
          const SizedBox(height: AppSpacing.xl),
          ToolActionBar(
            isSubmitting: viewModel.isSubmitting, 
            submittingText: l10n.toolsSplitSubmitting, 
            canAction: viewModel.canSplit, 
            icon: Icons.call_split, 
            label: l10n.toolsSplitButton, 
            hintText: l10n.toolsSplitButtonDisabledHint, 
            onAction: () {  },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: l10n.toolsSplitSourceSectionTitle,
          child: SingleFilePicker(
            filePath: viewModel.inputFilePath,
            onPickFile: viewModel.onPickFile,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: l10n.toolsSplitModeSectionTitle,
          child: _SplitModeEditor(viewModel: viewModel),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutputFilePicker(
          fileName: '',
          directoryPath: viewModel.outputDirectory,
          showFileName: false,
          onFileNameChanged: (_) {},
          onChooseFolder: viewModel.onChooseOutputFolder,
        ),
      ],
    );
  }
}

class _SplitModeEditor extends StatelessWidget {
  const _SplitModeEditor({required this.viewModel});

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<SplitPdfMode>(
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: SplitPdfMode.byPageCount,
              icon: const Icon(Icons.numbers_outlined, size: 18),
              label: Text(l10n.toolsSplitModeByPageCount),
            ),
            ButtonSegment(
              value: SplitPdfMode.bySelection,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.toolsSplitModeBySelection),
            ),
            ButtonSegment(
              value: SplitPdfMode.extractAllPages,
              icon: const Icon(Icons.content_copy_outlined, size: 18),
              label: Text(l10n.toolsSplitModeExtractAll),
            ),
          ],
          selected: {viewModel.mode},
          onSelectionChanged: (selection) =>
              viewModel.onModeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        switch (viewModel.mode) {
          SplitPdfMode.byPageCount => _ByPageCountEditor(viewModel: viewModel),
          SplitPdfMode.bySelection => _BySelectionEditor(viewModel: viewModel),
          SplitPdfMode.extractAllPages => Text(
              l10n.toolsSplitExtractAllInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        },
      ],
    );
  }
}

class _ByPageCountEditor extends StatelessWidget {
  const _ByPageCountEditor({required this.viewModel});

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: 220,
      child: TextField(
        key: const ValueKey('split-pages-per-file'),
        controller: TextEditingController(text: viewModel.pageCount),
        keyboardType: TextInputType.number,
        onChanged: viewModel.onPageCountChanged,
        decoration: InputDecoration(
          labelText: l10n.toolsSplitPagesPerFileLabel,
          hintText: l10n.toolsSplitPagesPerFileHint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _BySelectionEditor extends StatelessWidget {
  const _BySelectionEditor({required this.viewModel});

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.selections.isNotEmpty)
          for (var index = 0; index < viewModel.selections.length; index++)
            Padding(
              key: ValueKey('selection-$index'),
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PageSelectionField(
                      value: viewModel.selections[index],
                      fieldKey: ValueKey('selection-field-$index'),
                      onChanged: (value) => viewModel.onSelectionChanged(
                        index,
                        value,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: () => viewModel.onRemoveSelection(index),
                    tooltip: l10n.toolsSplitSelectionRemove,
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        if (viewModel.selections.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              l10n.toolsSplitSelectionHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: viewModel.onAddSelection,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsSplitSelectionAdd),
          ),
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
