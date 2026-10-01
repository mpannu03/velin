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
    on<DocumentWorkspaceSearch>(_onSearch);
    on<DocumentWorkspaceClearSearch>(_onClearSearch);
    on<DocumentWorkspaceSelectSearch>(_onSelectSearch);
    on<DocumentWorkspaceSelectBookmark>(_onSelectBookmark);
    on<DocumentWorkspaceSelectAnnotation>(_onSelectAnnotation);

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
  ) async {
    List<Bookmark> bookmarks = const [];

    if (_engine.capabilities.bookmarks) {
      bookmarks = await _engine.bookmark!.bookmarks;
    }

    emit(
      DocumentWorkspaceLoaded(
        currentPage: _engine.snapshot.currentPage,
        pageCount: _engine.snapshot.pageCount,
        currentZoom: _engine.snapshot.zoom,
        bookmarks: bookmarks,
      ),
    );

    if (_engine.capabilities.comments) {
      final annotations = await _engine.annotation!.annotations;

      if (emit.isDone) return;

      final currentState = state;

      if (currentState is! DocumentWorkspaceLoaded) {
        return;
      }

      emit(
        currentState.copyWith(
          annotations: annotations,
        ),
      );
    }
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

  void _onSearch(
    DocumentWorkspaceSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded 
          || !_engine.capabilities.textSelection
    ) {
      return;
    }

    currentState.copyWith(
      searchState: currentState.searchState.copyWith(
        results: const [],
        isLoading: true,
      ),
    );

    await emit.onEach(
      _engine.textSearch!.search(event.text, event.caseInsensitive), 
      onData: (textSearchResults) {
        emit(
          currentState.copyWith(
            searchState: currentState.searchState.copyWith(
              results: textSearchResults,
              isLoading: false,
            ),
          ),
        );
      }
    );

  }

  void _onClearSearch(
    DocumentWorkspaceClearSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async{
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    await _engine.textSearch?.clear();

    emit(
      currentState.copyWith(
        searchState: SearchState(),
      ),
    );
  }

  void _onSelectSearch(
    DocumentWorkspaceSelectSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded 
          || !_engine.capabilities.textSelection
    ) {
      return;
    }

    await _engine.textSearch?.selectResult(event.textSearchResult);

    emit(
      currentState.copyWith(
        searchState: currentState.searchState.copyWith(
          currentIndex: event.textSearchResult.index
        ),
      ),
    );
  }

  void _onSelectBookmark(
    DocumentWorkspaceSelectBookmark event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded
        || !_engine.capabilities.bookmarks
    ) {
      return;
    }

    _engine.bookmark?.goto(event.bookmark);
  }

  void _onSelectAnnotation(
    DocumentWorkspaceSelectAnnotation event,
    Emitter<DocumentWorkspaceState> emit
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded
        || !_engine.capabilities.comments
    ) {
      return;
    }

    _engine.annotation?.goto(event.annotation);
  }
}