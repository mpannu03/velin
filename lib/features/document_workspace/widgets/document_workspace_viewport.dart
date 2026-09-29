import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';

class DocumentWorkspaceViewport extends StatelessWidget {
  const DocumentWorkspaceViewport({
    required this.engine,
    super.key,
  });

  final DocumentEngine engine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: engine.buildViewer(
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}