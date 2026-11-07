import 'dart:async';

import 'package:velin/core/error/app_failure.dart';
import 'package:velin/core/error/map_error.dart';

/// The outcome of an operation that can fail in an expected way.
///
/// A [Failure] always carries an [AppFailure], never a raw exception, so
/// callers can `switch` over what went wrong.
sealed class Result<T> {
  const Result();

  /// Runs [body] and wraps its value in [Success], or maps anything it throws
  /// to a [Failure] via [mapError].
  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Success(await body());
    } catch (error, stackTrace) {
      return Failure(mapError(error, stackTrace));
    }
  }

  /// Synchronous variant of [guard].
  static Result<T> guardSync<T>(T Function() body) {
    try {
      return Success(body());
    } catch (error, stackTrace) {
      return Failure(mapError(error, stackTrace));
    }
  }

  /// Wraps each event of [source] in [Success] and turns stream errors into
  /// [Failure] events, so subscribers never see a raw error.
  static Stream<Result<T>> guardStream<T>(Stream<T> source) {
    return source.transform(
      StreamTransformer<T, Result<T>>.fromHandlers(
        handleData: (data, sink) => sink.add(Success(data)),
        handleError: (error, stackTrace, sink) =>
            sink.add(Failure(mapError(error, stackTrace))),
      ),
    );
  }

  /// The failure, or `null` on success.
  AppFailure? get failureOrNull => null;
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

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
  const Failure(this.failure);

  final AppFailure failure;

  @override
  AppFailure get failureOrNull => failure;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(Failure, failure);

  @override
  String toString() => 'Failure($failure)';
}
