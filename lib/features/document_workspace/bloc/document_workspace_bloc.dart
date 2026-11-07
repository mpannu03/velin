import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/services/dictionary/dictionary.dart';
import 'package:velin/shared/utils/utils.dart';

import '../models/models.dart';
import 'document_workspace_listener.dart';

part 'document_workspace_event.dart';
part 'document_workspace_state.dart';
part 'search_state.dart';
part 'dictionary_state.dart';

class DocumentWorkspaceBloc
    extends Bloc<DocumentWorkspaceEvent, DocumentWorkspaceState> {
  DocumentWorkspaceBloc({
    required this._engine,
    required this._recentDocumentService,
    required this._dictionaryService,
    required this._appEffectController,
  }) : super(const DocumentWorkspaceInitial()) {
    on<DocumentWorkspaceStarted>(_onStarted);
    on<DocumentWorkspacePageChanged>(_onPageChanged);
    on<DocumentWorkspaceZoomChanged>(_onZoomChanged);
    on<DocumentWorkspaceToolSelected>(_onToolSelected);
    on<DocumentWorkspacePanelSelected>(_onPanelSelected);
    on<DocumentWorkspacePanelClosed>(_onPanelClosed);
    on<DocumentWorkspaceReady>(_onReady);
    // A new search or lookup cancels the one in flight, so a slow earlier
    // result can never overwrite a newer one.
    on<DocumentWorkspaceSearch>(_onSearch, transformer: restartable());
    on<DocumentWorkspaceClearSearch>(_onClearSearch);
    on<DocumentWorkspaceSelectSearch>(_onSelectSearch);
    on<DocumentWorkspaceSelectBookmark>(_onSelectBookmark);
    on<DocumentWorkspaceSelectAnnotation>(_onSelectAnnotation);
    on<DocumentWorkspaceTextSelected>(_onTextSelected);
    on<DocumentWorkspaceDictionaryLookup>(
      _onDictionaryLookup,
      transformer: restartable(),
    );
    on<DocumentWorkspaceClearDictionary>(_onClearDictionary);

    _engine.listener = DocumentWorkspaceListener(bloc: this);
  }

  final DocumentEngine _engine;
  final RecentDocumentService _recentDocumentService;
  final DictionaryService _dictionaryService;
  final AppEffectController _appEffectController;

  Future<void> _onStarted(
    DocumentWorkspaceStarted event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final recentDocument = await _recentDocumentService.get(
      _engine.document.path,
    );

    if (emit.isDone) return;

    // No saved position (or it could not be read): start at the first page.
    final initialPage = switch (recentDocument) {
      Success(data: RecentDocument(:final currentPage)) => currentPage,
      _ => 1,
    };

    emit(DocumentWorkspaceOpening(initialPageNumber: initialPage));
  }

  Future<void> _onReady(
    DocumentWorkspaceReady event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentPage = _engine.snapshot.currentPage ?? 1;
    final pageCount = _engine.snapshot.pageCount;
    final currentZoom = _engine.snapshot.zoom;

    // Never fails: problems with the recent list are logged, not shown.
    await _recentDocumentService.open(
      path: _engine.document.path,
      pageCount: pageCount,
      currentPage: currentPage,
      documentType: _engine.document.type,
    );

    if (emit.isDone) {
      return;
    }

    List<Bookmark> bookmarks = const [];

    if (_engine.capabilities.bookmarks) {
      bookmarks = await _engine.bookmark!.bookmarks;
    }

    if (emit.isDone) {
      return;
    }

    emit(
      DocumentWorkspaceLoaded(
        currentPage: currentPage,
        pageCount: pageCount,
        currentZoom: currentZoom,
        bookmarks: bookmarks,
      ),
    );

    if (_engine.capabilities.comments) {
      final annotations = await _engine.annotation!.annotations;

      if (emit.isDone) {
        return;
      }

      final currentState = state;

      if (currentState is! DocumentWorkspaceLoaded) {
        return;
      }

      emit(currentState.copyWith(annotations: annotations));
    }
  }

  void _onPageChanged(
    DocumentWorkspacePageChanged event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final page = event.page;

    if (page == null) {
      return;
    }

    _recentDocumentService.pageChanged(
      path: _engine.document.path,
      currentPage: page,
    );

    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(currentState.copyWith(currentPage: page));
  }

  void _onZoomChanged(
    DocumentWorkspaceZoomChanged event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(currentState.copyWith(currentZoom: event.zoom));
  }

  void _onToolSelected(
    DocumentWorkspaceToolSelected event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(currentState.copyWith(selectedTool: event.tool));
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

    emit(currentState.copyWith(selectedPanel: event.panel));
  }

  void _onPanelClosed(
    DocumentWorkspacePanelClosed event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(currentState.copyWith(selectedPanel: null));
  }

  Future<void> _onSearch(
    DocumentWorkspaceSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded ||
        !_engine.capabilities.textSelection) {
      return;
    }

    emit(
      currentState.copyWith(
        searchState: currentState.searchState.copyWith(
          results: const [],
          isLoading: true,
        ),
      ),
    );

    await emit.onEach(
      _engine.textSearch!.search(event.text, event.caseInsensitive),
      onData: (textSearchResults) {
        final currentState = state;

        if (currentState is! DocumentWorkspaceLoaded) {
          return;
        }

        emit(
          currentState.copyWith(
            searchState: currentState.searchState.copyWith(
              results: textSearchResults,
              isLoading: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onClearSearch(
    DocumentWorkspaceClearSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    await _engine.textSearch?.clear();

    _emitLoaded(
      emit,
      (loaded) => loaded.copyWith(searchState: const SearchState()),
    );
  }

  Future<void> _onSelectSearch(
    DocumentWorkspaceSelectSearch event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded ||
        !_engine.capabilities.textSelection) {
      return;
    }

    await _engine.textSearch?.selectResult(event.textSearchResult);

    _emitLoaded(
      emit,
      (loaded) => loaded.copyWith(
        searchState: loaded.searchState.copyWith(
          currentIndex: event.textSearchResult.index,
        ),
      ),
    );
  }

  Future<void> _onSelectBookmark(
    DocumentWorkspaceSelectBookmark event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded ||
        !_engine.capabilities.bookmarks) {
      return;
    }

    _engine.bookmark?.goto(event.bookmark);
  }

  Future<void> _onSelectAnnotation(
    DocumentWorkspaceSelectAnnotation event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded ||
        !_engine.capabilities.comments) {
      return;
    }

    _engine.annotation?.goto(event.annotation);
  }

  void _onTextSelected(
    DocumentWorkspaceTextSelected event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded ||
        !_engine.capabilities.textSelection ||
        event.text.trim().isEmpty) {
      return;
    }

    if (currentState.selectedTool == WorkspaceTool.dictionary) {
      emit(currentState.copyWith(selectedPanel: WorkspacePanel.dictionary));
      add(DocumentWorkspaceDictionaryLookup(event.text));
    }
  }

  Future<void> _onDictionaryLookup(
    DocumentWorkspaceDictionaryLookup event,
    Emitter<DocumentWorkspaceState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded || event.text.trim().isEmpty) {
      return;
    }

    emit(
      currentState.copyWith(
        dictionaryState: DictionaryState(
          query: event.text,
          result: null,
          isLoading: true,
        ),
      ),
    );

    final result = await _dictionaryService.lookup(event.text.trim());

    // Superseded by a newer lookup (restartable) or the bloc closed.
    if (emit.isDone) return;

    final entry = switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };

    _emitLoaded(
      emit,
      (loaded) => loaded.copyWith(
        dictionaryState: DictionaryState(
          query: event.text,
          result: entry,
          isLoading: false,
        ),
      ),
    );

    if (result case Failure(:final failure)) {
      _appEffectController.notifyFailure(failure);
    }
  }

  /// Applies [update] to the *current* loaded state.
  ///
  /// Handlers that await must use this instead of a state captured before the
  /// await; otherwise changes made meanwhile (page, zoom, panel, ...) would be
  /// silently reverted.
  void _emitLoaded(
    Emitter<DocumentWorkspaceState> emit,
    DocumentWorkspaceLoaded Function(DocumentWorkspaceLoaded loaded) update,
  ) {
    final current = state;

    if (emit.isDone || current is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(update(current));
  }

  void _onClearDictionary(
    DocumentWorkspaceClearDictionary event,
    Emitter<DocumentWorkspaceState> emit,
  ) {
    final currentState = state;

    if (currentState is! DocumentWorkspaceLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        dictionaryState: DictionaryState(
          query: "",
          result: null,
          isLoading: false,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _recentDocumentService.flush(_engine.document.path);
    return super.close();
  }
}
