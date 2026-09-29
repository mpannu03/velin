import 'package:material_ui/material_ui.dart';

import '../../models/models.dart';

class DocumentWorkspacePanel extends StatelessWidget {
  const DocumentWorkspacePanel({
    required this.panel,
    required this.onClose,
    super.key,
  });

  final WorkspacePanel panel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: SizedBox(
        width: 320,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Center(
                child: Text('$_title panel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    return switch (panel) {
      WorkspacePanel.comments => 'Comments',
      WorkspacePanel.annotations => 'Annotations',
    };
  }
}