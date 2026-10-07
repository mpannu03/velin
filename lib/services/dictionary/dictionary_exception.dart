sealed class DictionaryException implements Exception {
  const DictionaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DictionaryNotFoundException extends DictionaryException {
  const DictionaryNotFoundException(this.word)
    : super('No Dictionary entry found for "$word".');

  final String word;
}

class DictionaryHttpException extends DictionaryException {
  const DictionaryHttpException({required this.statusCode, required this.word})
    : super('Dictionary request failed with HTTP status $statusCode.');

  final int statusCode;
  final String word;
}

class DictionaryResponseException extends DictionaryException {
  const DictionaryResponseException(super.message);
}
