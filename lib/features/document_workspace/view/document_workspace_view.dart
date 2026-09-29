import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../layout/layout.dart';
import 'document_workspace_view_model.dart';

class DocumentWorkspaceView extends StatelessWidget {
  const DocumentWorkspaceView({
    required this.viewModel,
    super.key,
  });

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: DocumentWorkspaceDesktopLayout(
        viewModel: viewModel
      ), 
      mobilePortrait: DocumentWorkspaceMobileLayout(
        viewModel: viewModel
      ),
    );
  } 
}