import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/result/result.dart';

void main() {
  group('Success', () {
    test('stores data and has no failure', () {
      const result = Success<int>(42);

      expect(result.data, 42);
      expect(result.failureOrNull, isNull);
    });

    test('is equal when data is equal', () {
      expect(const Success<int>(42), equals(const Success<int>(42)));
    });

    test('is not equal when data differs', () {
      expect(const Success<int>(42), isNot(equals(const Success<int>(43))));
    });

    test('has matching hashCode for equal results', () {
      expect(const Success<int>(42).hashCode, const Success<int>(42).hashCode);
    });

    test('has expected string representation', () {
      expect(const Success<int>(42).toString(), 'Success(42)');
    });
  });

  group('Failure', () {
    test('stores the failure', () {
      const failure = FileNotFoundFailure(path: '/a.pdf');
      const result = Failure<int>(failure);

      expect(result.failure, same(failure));
      expect(result.failureOrNull, same(failure));
    });

    test('is equal when the failure is the same', () {
      const failure = DiskFullFailure();

      expect(const Failure<int>(failure), equals(const Failure<int>(failure)));
    });

    test('is not equal when the failure differs', () {
      expect(
        Failure<int>(FileNotFoundFailure(path: 'a')),
        isNot(equals(Failure<int>(FileNotFoundFailure(path: 'a')))),
      );
    });

    test('has expected string representation', () {
      expect(
        const Failure<int>(DiskFullFailure()).toString(),
        'Failure(DiskFullFailure)',
      );
    });
  });

  group('Result.guard', () {
    test('wraps the value in Success', () async {
      expect(await Result.guard(() async => 7), const Success(7));
    });

    test('maps a thrown exception to a typed Failure', () async {
      final result = await Result.guard<int>(
        () async => throw const PathNotFoundException(
          '/missing.pdf',
          OSError('not found', 2),
        ),
      );

      expect(
        result.failureOrNull,
        isA<FileNotFoundFailure>().having(
          (f) => f.path,
          'path',
          '/missing.pdf',
        ),
      );
    });

    test('passes an AppFailure through unchanged', () async {
      const failure = WrongPasswordFailure();

      final result = await Result.guard<int>(() async => throw failure);

      expect(result.failureOrNull, same(failure));
    });
  });

  group('Result.guardSync', () {
    test('wraps the value and maps errors', () {
      expect(Result.guardSync(() => 'ok'), const Success('ok'));
      expect(
        Result.guardSync<int>(() => throw StateError('bug')).failureOrNull,
        isA<UnexpectedFailure>(),
      );
    });
  });

  group('Result.guardStream', () {
    test('turns data into Success and errors into Failure', () async {
      final controller = StreamController<int>();
      final results = Result.guardStream(controller.stream).toList();

      controller
        ..add(1)
        ..addError(TimeoutException('slow'))
        ..add(2);
      await controller.close();

      final events = await results;

      expect(events[0], const Success(1));
      expect(
        events[1].failureOrNull,
        isA<NetworkFailure>().having((f) => f.isTimeout, 'isTimeout', isTrue),
      );
      expect(events[2], const Success(2));
    });
  });
}
