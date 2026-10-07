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
  }) : super(HomeState()) {
    on<HomeStarted>(_onStarted);

    on<HomeRecentDocumentSelected>(_onRecentSelected);
  }

  final RecentDocumentService _recentDocumentService;
  final DocumentService _documentService;

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final data = _recentDocumentService.watchRecent();

    await emit.onEach(
      data,
      onData: (result) {
        switch (result) {
          case Success(:final data):
            emit(HomeState(recentDocuments: data));
          case Failure():
            break;
        }
      },
    );
  }

  void _onRecentSelected(
    HomeRecentDocumentSelected event,
    Emitter<HomeState> emit,
  ) {
    _documentService.openRecent(event.recentDocument);
  }
}
