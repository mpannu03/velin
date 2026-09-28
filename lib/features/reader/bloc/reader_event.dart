part of 'reader_bloc.dart';

sealed class ReaderEvent {
  const ReaderEvent();
}

final class ReaderStarted extends ReaderEvent {
  const ReaderStarted();
}

final class ReaderDocumentOpened extends ReaderEvent {
  const ReaderDocumentOpened();
}

final class ReaderDocumentSelected extends ReaderEvent {
  const ReaderDocumentSelected(this.document);

  final Document document;
}

final class ReaderDocumentClosed extends ReaderEvent {
  const ReaderDocumentClosed(this.document);

  final Document document;
}