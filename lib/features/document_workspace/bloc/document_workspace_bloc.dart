import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart';

part 'document_workspace_event.dart';
part 'document_workspace_state.dart';

class DocumentWorkspaceBloc
    extends Bloc<DocumentWorkspaceEvent, DocumentWorkspaceState> {
  DocumentWorkspaceBloc() : super(const DocumentWorkspaceInitial()) {
    on<DocumentWorkspaceStarted>(_onStarted);
    on<DocumentWorkspacePageChanged>(_onPageChanged);
    on<DocumentWorkspaceZoomChanged>(_onZoomChanged);
    on<DocumentWorkspaceToolSelected>(_onToolSelected);
    on<DocumentWorkspacePanelSelected>(_onPanelSelected);
    on<DocumentWorkspacePanelClosed>(_onPanelClosed);
  }

  void _onStarted(
    DocumentWorkspaceStarted event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    emit(const DocumentWorkspaceLoading());

    emit(
      DocumentWorkspaceLoaded(
        currentPage: event.currentPage,
        pageCount: event.pageCount,
        currentZoom: event.currentZoom,
      ),
    );
  }

  void _onPageChanged(
    DocumentWorkspacePageChanged event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        currentPage: event.page,
      ),
    );
  }

  void _onZoomChanged(
    DocumentWorkspaceZoomChanged event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        currentZoom: event.zoom,
      ),
    );
  }

  void _onToolSelected(
    DocumentWorkspaceToolSelected event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        selectedTool: event.tool,
      ),
    );
  }

  void _onPanelSelected(
    DocumentWorkspacePanelSelected event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    if (currentState.selectedPanel == event.panel) {
      add(const DocumentWorkspacePanelClosed());
      return;
    }

    emit(
      currentState.copyWith(
        selectedPanel: event.panel,
      ),
    );
  }

  void _onPanelClosed(
    DocumentWorkspacePanelClosed event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        selectedPanel: null,
      ),
    );
  }
}