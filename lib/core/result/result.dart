sealed class Result<T> {
  const Result();

  Object? get error => null;
  StackTrace? get stackTrace => null;
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success && other.data == data;
  }

  @override
  int get hashCode => Object.hash(Success, data);

  @override
  String toString() => 'Success($data)';
}

final class Failure<T> extends Result<T> {
  @override
  final Object error;

  @override
  final StackTrace? stackTrace;

  const Failure(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode => Object.hash(Failure, error, stackTrace);

  @override
  String toString() => 'Failure($error)';
}