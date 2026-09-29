import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';

import '../models/models.dart';

part 'document_workspace_event.dart';
part 'document_workspace_state.dart';

class DocumentWorkspaceBloc
    extends Bloc<DocumentWorkspaceEvent, DocumentWorkspaceState> {
  DocumentWorkspaceBloc({
    required this._document,
    required this._engineFactory,
  })  : super(const DocumentWorkspaceInitial()) {
    on<DocumentWorkspaceStarted>(_onStarted);
    on<DocumentWorkspaceToolSelected>(_onToolSelected);
    on<DocumentWorkspacePanelSelected>(_onPanelSelected);
    on<DocumentWorkspacePanelClosed>(_onPanelClosed);
  }

  final Document _document;
  final DocumentEngineFactory _engineFactory;
  DocumentEngine? _engine;

  @override
  Future<void> close() async {
    await _engine?.dispose();
    return super.close();
  }

  void _onStarted(
    DocumentWorkspaceStarted event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    emit(const DocumentWorkspaceLoading());

    try {
      final engine = _engineFactory.create(_document);
      _engine = engine;

      emit(
        DocumentWorkspaceLoaded(
          engine: engine,
          currentPage: engine.controller.currentPage,
          pageCount: engine.controller.pageCount,
        ),
      );

      await emit.onEach<int?>(
        engine.controller.currentPageStream,
        onData: (currentPage) {
          final currentState = state;

          if (currentState is! DocumentWorkspaceLoaded) {
            return;
          }

          emit(
            currentState.copyWith(
              currentPage: currentPage,
            ),
          );
        },
      );
    } on Object catch (error) {
      emit(
        DocumentWorkspaceError(
          error.toString(),
        ),
      );
    }
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
      add(DocumentWorkspacePanelClosed());
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