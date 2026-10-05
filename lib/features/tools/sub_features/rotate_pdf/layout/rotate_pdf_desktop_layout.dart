import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class RotatePdfDesktopLayout extends StatelessWidget {
  const RotatePdfDesktopLayout({super.key, required this.viewModel});

  final RotatePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsRotatePdf,
      description: l10n.toolsRotateIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsRotateSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsRotateDirectionSectionTitle,
              child: DirectionSelector(
                direction: viewModel.direction,
                onDirectionChanged: viewModel.onDirectionChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsRotatePagesSectionTitle,
              child: PageScopeEditor<RotatePdfPageScope>(
                allPagesScope: RotatePdfPageScope.allPages,
                selectedPagesScope: RotatePdfPageScope.selectedPages,
                scope: viewModel.scope,
                requiresSelection: viewModel.scope.requiresSelection,
                allPagesLabel: l10n.toolsRotateScopeAll,
                selectedPagesLabel: l10n.toolsRotateScopeSelected,
                onScopeChanged: viewModel.onScopeChanged,
                selection: viewModel.selection,
                selectionFieldKey: const ValueKey('rotate-page-selection'),
                selectionHintText: l10n.toolsRotateSelectionHint,
                selectionHelperText: l10n.toolsRotateSelectionHelper,
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
              submittingText: l10n.toolsRotateSubmitting,
              canAction: viewModel.canRotate,
              icon: Icons.rotate_right,
              label: l10n.toolsRotateButton,
              hintText: l10n.toolsRotateButtonDisabledHint,
              onAction: viewModel.onRotate,
            ),
          ],
        ],
      ),
    );
  }
}
