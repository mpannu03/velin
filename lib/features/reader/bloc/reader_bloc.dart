import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/bloc/bloc.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';

part 'reader_event.dart';
part 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> with ErrorMessageMixin {
  ReaderBloc({
    required this._documentService,
    required this._appEffectController,
  }) : super(const ReaderInitial()) {
    on<ReaderStarted>(_onStarted);
    on<ReaderDocumentOpened>(_onDocumentOpened);
    on<ReaderDocumentSelected>(_onDocumentSelected);
    on<ReaderDocumentClosed>(_onDocumentClosed);
  }

  final DocumentService _documentService;
  final AppEffectController _appEffectController;

  Future<void> _onStarted(
    ReaderStarted event,
    Emitter<ReaderState> emit,
  ) async {
    emit(const ReaderLoading());

    await emit.onEach<List<Document>>(
      _documentService.watch(),
      onData: (documents) {
        final currentState = state;

        if (currentState is ReaderLoaded) {
          final selectedDocument = currentState.selectedDocument;

          emit(
            currentState.copyWith(
              documents: documents,
              selectedDocument: documents.contains(selectedDocument)
                  ? selectedDocument
                  : documents.isEmpty
                  ? null
                  : documents.first,
            ),
          );

          return;
        }

        emit(
          ReaderLoaded(
            documents: documents,
            selectedDocument: documents.isEmpty ? null : documents.first,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(ReaderError(errorMessage(error)));
      },
    );
  }

  Future<void> _onDocumentOpened(
    ReaderDocumentOpened event,
    Emitter<ReaderState> emit,
  ) async {
    final result = await _documentService.open();

    if (result case Failure<Document>(:final error)) {
      _appEffectController.notifyUser(
        message: errorMessage(error),
        type: NotificationType.error,
      );
    }
  }

  void _onDocumentSelected(
    ReaderDocumentSelected event,
    Emitter<ReaderState> emit,
  ) {
    final currentState = state;

    if (currentState is! ReaderLoaded) {
      return;
    }

    if (!currentState.documents.contains(event.document)) {
      return;
    }

    emit(currentState.copyWith(selectedDocument: event.document));
  }

  void _onDocumentClosed(
    ReaderDocumentClosed event,
    Emitter<ReaderState> emit,
  ) {
    final result = _documentService.close(event.document);

    if (result case Failure<void>(:final error)) {
      _appEffectController.notifyUser(
        message: errorMessage(error),
        type: NotificationType.error,
      );
    }
  }
}
