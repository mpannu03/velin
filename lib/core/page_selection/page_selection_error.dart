sealed class PageSelectionError implements Exception {
  const PageSelectionError();

  String get message;
}

final class EmptyPageSelectionError extends PageSelectionError {
  const EmptyPageSelectionError();

  @override
  String get message => 'Input cannot be empty';
}

final class InvalidPageSelectionTokenError extends PageSelectionError {
  const InvalidPageSelectionTokenError(this.token);

  final String token;

  @override
  String get message => 'Invalid token: $token';
}

final class InvalidPageSelectionRangeError extends PageSelectionError {
  const InvalidPageSelectionRangeError(this.range);

  final String range;

  @override
  String get message => 'Invalid range: $range';
}

final class InvalidPageSelectionNumberError extends PageSelectionError {
  const InvalidPageSelectionNumberError(this.number);

  final String number;

  @override
  String get message => 'Invalid number: $number';
}

final class PageSelectionOutOfBoundsError extends PageSelectionError {
  const PageSelectionOutOfBoundsError({
    required this.page,
    required this.totalPages,
  });

  final int page;
  final int totalPages;

  @override
  String get message => 'Page $page exceeds document length $totalPages';
}
