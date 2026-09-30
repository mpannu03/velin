import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/core/document/engine/engine.dart';

import '../models/models.dart';
import 'document_workspace_listener.dart';

part 'document_workspace_event.dart';
part 'document_workspace_state.dart';

class DocumentWorkspaceBloc
    extends Bloc<DocumentWorkspaceEvent, DocumentWorkspaceState> {
  DocumentWorkspaceBloc({
    required this._engine,
  }) : super(const DocumentWorkspaceInitial()) {
    on<DocumentWorkspaceStarted>(_onStarted);
    on<DocumentWorkspacePageChanged>(_onPageChanged);
    on<DocumentWorkspaceZoomChanged>(_onZoomChanged);
    on<DocumentWorkspaceToolSelected>(_onToolSelected);
    on<DocumentWorkspacePanelSelected>(_onPanelSelected);
    on<DocumentWorkspacePanelClosed>(_onPanelClosed);
    on<DocumentWorkspaceReady>(_onReady);

    _engine.listener = DocumentWorkspaceListener(bloc: this);
  }

  final DocumentEngine _engine;

  void _onStarted(
    DocumentWorkspaceStarted event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    emit(const DocumentWorkspaceLoading());

    emit(
      DocumentWorkspaceLoaded(
        currentPage: 0,
        pageCount: 0,
        currentZoom: 1.0,
      ),
    );
  }

  void _onReady(
    DocumentWorkspaceReady event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    emit(
      DocumentWorkspaceLoaded(
        currentPage: _engine.snapshot.currentPage,
        pageCount: _engine.snapshot.pageCount,
        currentZoom: _engine.snapshot.zoom,
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