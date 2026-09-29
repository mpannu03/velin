import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../models/models.dart';

class DocumentWorkspacePanelRail extends StatelessWidget {
  const DocumentWorkspacePanelRail({
    required this.selectedPanel,
    required this.onPanelSelected,
    super.key,
  });

  final WorkspacePanel? selectedPanel;
  final ValueChanged<WorkspacePanel> onPanelSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            VelinIconButton(
              icon: Icons.comment_outlined,
              tooltip: 'Comments',
              onPressed: () => onPanelSelected(WorkspacePanel.comments),
              isSelected: selectedPanel == WorkspacePanel.comments,
            ),
            VelinIconButton(
              icon: Icons.sticky_note_2_outlined,
              tooltip: 'Annotations',
              onPressed: () => onPanelSelected(WorkspacePanel.annotations),
              isSelected: selectedPanel == WorkspacePanel.annotations,
            ),
          ],
        ),
      ),
    );
  }
}