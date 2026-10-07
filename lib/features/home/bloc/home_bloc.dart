import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/shared/utils/utils.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this._recentDocumentService,
    required this._documentService,
  }) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);

    on<HomeRecentDocumentSelected>(_onRecentSelected);
    on<HomeOpenRequested>(_onOpenRequested);
  }

  final RecentDocumentService _recentDocumentService;
  final DocumentService _documentService;

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final data = _recentDocumentService.watchRecent(limit: 12);

    await emit.onEach(
      data,
      onData: (result) {
        switch (result) {
          case Success(:final data):
            emit(state.copyWith(recentDocuments: data, clearOpenFailure: true));
          case Failure():
            break;
        }
      },
    );
  }

  void _onRecentSelected(
    HomeRecentDocumentSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isOpening: true, clearOpenFailure: true));

    final result = await _documentService.openRecent(event.recentDocument);

    switch (result) {
      case Success():
        emit(state.copyWith(isOpening: false, openToken: state.openToken + 1));
      case Failure(:final error):
        emit(state.copyWith(isOpening: false, openFailure: error));
    }
  }

  void _onOpenRequested(
    HomeOpenRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isOpening) return;
    emit(state.copyWith(isOpening: true, clearOpenFailure: true));

    final result = await _documentService.open();

    switch (result) {
      case Success():
        emit(state.copyWith(isOpening: false, openToken: state.openToken + 1));
      case Failure(:final error):
        // File picker cancellation surfaces as failure — stay quiet and
        // simply reset the opening flag without showing an error.
        emit(state.copyWith(isOpening: false, openFailure: error));
    }
  }
}
