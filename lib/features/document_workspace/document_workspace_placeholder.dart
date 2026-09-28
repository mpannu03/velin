import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';

class DocumentWorkspacePlaceholder extends StatelessWidget {
  const DocumentWorkspacePlaceholder({
    super.key, 
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Workspace for ${document.path}'),
    );
  }
  
}