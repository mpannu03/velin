import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';

import '../bloc/bloc.dart';
import 'document_workspace_view.dart';
import 'document_workspace_view_model.dart';

class DocumentWorkspacePage extends StatelessWidget {
  const DocumentWorkspacePage({
    required this.document,
    super.key,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DocumentWorkspaceBloc>(param1: document)
          ..add(const DocumentWorkspaceStarted()),
      child: BlocBuilder<DocumentWorkspaceBloc, DocumentWorkspaceState>(
        builder: (context, state) {
          return switch (state) {
            DocumentWorkspaceInitial() ||
            DocumentWorkspaceLoading() =>
              const Center(
                child: CircularProgressIndicator(),
              ),
            DocumentWorkspaceLoaded() => DocumentWorkspaceView(
              viewModel: DocumentWorkspaceViewModel(
                engine: state.engine,
                selectedTool: state.selectedTool,
                selectedPanel: state.selectedPanel,
                onToolSelected: (tool) {
                  context.read<DocumentWorkspaceBloc>().add(
                        DocumentWorkspaceToolSelected(tool),
                      );
                },
                onPanelSelected: (panel) {
                  context.read<DocumentWorkspaceBloc>().add(
                        DocumentWorkspacePanelSelected(panel),
                      );
                },
                onPanelClosed: () {
                  context.read<DocumentWorkspaceBloc>().add(
                        const DocumentWorkspacePanelClosed(),
                      );
                },
              ),
            ),
            DocumentWorkspaceError(:final message) => Center(
              child: Text(message),
            ),
          };
        },
      ),
    );
  }
}