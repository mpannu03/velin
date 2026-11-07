import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/shared/utils/utils.dart';

part 'home_event.dart';
part 'home_state.dart';

final _log = Logger('velin.home');

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this._recentDocumentService,
    required this._documentService,
    required this._appEffectController,
  }) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);

    on<HomeRecentDocumentSelected>(_onRecentSelected);
    on<HomeOpenRequested>(_onOpenRequested);
  }

  final RecentDocumentService _recentDocumentService;
  final DocumentService _documentService;
  final AppEffectController _appEffectController;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final data = _recentDocumentService.watchRecent(limit: 12);

    await emit.onEach(
      data,
      onData: (result) {
        switch (result) {
          case Success(:final data):
            emit(state.copyWith(recentDocuments: data));
          case Failure(:final failure):
            // Keep showing the last known list; recents are not critical.
            _log.warning('Could not load recent documents', failure);
        }
      },
    );
  }

  Future<void> _onRecentSelected(
    HomeRecentDocumentSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isOpening: true));

    final result = await _documentService.openRecent(event.recentDocument);

    switch (result) {
      case Success():
        emit(state.copyWith(isOpening: false, openToken: state.openToken + 1));
      case Failure(:final failure):
        emit(state.copyWith(isOpening: false));
        _appEffectController.notifyFailure(failure);
    }
  }

  Future<void> _onOpenRequested(
    HomeOpenRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isOpening) return;
    emit(state.copyWith(isOpening: true));

    final result = await _documentService.open();

    switch (result) {
      case Success(data: null):
        // The user cancelled the picker.
        emit(state.copyWith(isOpening: false));
      case Success():
        emit(state.copyWith(isOpening: false, openToken: state.openToken + 1));
      case Failure(:final failure):
        emit(state.copyWith(isOpening: false));
        _appEffectController.notifyFailure(failure);
    }
  }
}
