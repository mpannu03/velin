import 'package:velin/core/document/engine/engine.dart';

import 'document_workspace_bloc.dart';

class DocumentWorkspaceListener implements DocumentEngineListener {
  const DocumentWorkspaceListener({required this._bloc});

  final DocumentWorkspaceBloc _bloc;

  @override
  void onPageChanged(int? page) {
    _bloc.add(DocumentWorkspacePageChanged(page));
  }

  @override
  void onReady() {
    _bloc.add(const DocumentWorkspaceReady());
  }

  @override
  void onZoomChanged(double zoom) {
    _bloc.add(DocumentWorkspaceZoomChanged(zoom));
  }

  @override
  void onTextSelected(String text) {
    _bloc.add(DocumentWorkspaceTextSelected(text));
  }
}
