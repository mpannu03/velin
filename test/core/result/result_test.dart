import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/result/result.dart';

void main() {
  group('Success', () {
    test('stores data', () {
      const result = Success<int>(42);

      expect(result.data, 42);
      expect(result.error, isNull);
      expect(result.stackTrace, isNull);
    });

    test('is equal when data is equal', () {
      expect(
        const Success<int>(42),
        equals(const Success<int>(42)),
      );
    });

    test('is not equal when data differs', () {
      expect(
        const Success<int>(42),
        isNot(equals(const Success<int>(43))),
      );
    });

    test('has matching hashCode for equal results', () {
      expect(
        const Success<int>(42).hashCode,
        const Success<int>(42).hashCode,
      );
    });

    test('has expected string representation', () {
      expect(
        const Success<int>(42).toString(),
        'Success(42)',
      );
    });
  });

  group('Failure', () {
    test('stores error and stack trace', () {
      final stackTrace = StackTrace.current;
      final result = Failure<int>('Something went wrong', stackTrace);

      expect(result.error, 'Something went wrong');
      expect(result.stackTrace, stackTrace);
    });

    test('stack trace is optional', () {
      const result = Failure<int>('Something went wrong');

      expect(result.error, 'Something went wrong');
      expect(result.stackTrace, isNull);
    });

    test('is equal when error and stack trace are equal', () {
      final stackTrace = StackTrace.current;

      expect(
        Failure<int>('error', stackTrace),
        equals(Failure<int>('error', stackTrace)),
      );
    });

    test('is not equal when error differs', () {
      expect(
        const Failure<int>('error'),
        isNot(equals(const Failure<int>('other error'))),
      );
    });

    test('is not equal when stack trace differs', () {
      final first = StackTrace.fromString('trace 1');
      final second = StackTrace.fromString('trace 2');

      expect(
        Failure<int>('error', first),
        isNot(equals(Failure<int>('error', second))),
      );
    });

    test('has expected string representation', () {
      expect(
        const Failure<int>('Something went wrong').toString(),
        'Failure(Something went wrong)',
      );
    });
  });
}