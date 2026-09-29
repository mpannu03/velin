import 'package:material_ui/material_ui.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VelinIconButton(
          icon: Icons.comment_outlined,
          tooltip: 'Comments',
          onPressed: () => onPanelSelected(WorkspacePanel.comments),
        ),
        VelinIconButton(
          icon: Icons.sticky_note_2_outlined,
          tooltip: 'Annotations',
          onPressed: () => onPanelSelected(WorkspacePanel.annotations),
        ),
      ],
    );
  }
}