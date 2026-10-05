part of 'reader_bloc.dart';

sealed class ReaderState {
  const ReaderState();
}

final class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

final class ReaderLoading extends ReaderState {
  const ReaderLoading();
}

final class ReaderLoaded extends ReaderState {
  const ReaderLoaded({required this.documents, this.selectedDocument});

  factory ReaderLoaded.empty() =>
      ReaderLoaded(documents: [], selectedDocument: null);

  final List<Document> documents;
  final Document? selectedDocument;

  ReaderLoaded copyWith({
    List<Document>? documents,
    Object? selectedDocument = _unset,
  }) {
    return ReaderLoaded(
      documents: documents ?? this.documents,
      selectedDocument: identical(selectedDocument, _unset)
          ? this.selectedDocument
          : selectedDocument as Document?,
    );
  }
}

final class ReaderError extends ReaderState {
  const ReaderError(this.message);

  final String message;
}

const _unset = Object();
