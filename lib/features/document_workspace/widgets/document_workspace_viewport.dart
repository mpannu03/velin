import 'package:material_ui/material_ui.dart';

class DocumentWorkspaceViewport extends StatelessWidget {
  const DocumentWorkspaceViewport({
    required this.documentViewer,
    super.key,
  });

  final Widget documentViewer;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: documentViewer,
    );
  }
}