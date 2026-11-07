import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/task/task.dart';

void main() {
  group('TaskContext', () {
    test('throwIfCancelled throws CancelledFailure once cancelled', () {
      final context = TaskContext.detached();

      expect(context.throwIfCancelled, returnsNormally);

      context.token.cancel();

      expect(context.isCancelled, isTrue);
      expect(context.throwIfCancelled, throwsA(isA<CancelledFailure>()));
    });

    test('reportProgress reports a clamped fraction', () {
      final reported = <double>[];
      final context = TaskContext(onProgress: reported.add);

      context
        ..reportProgress(1, 4)
        ..reportProgress(5, 4)
        ..reportProgress(1, 0);

      expect(reported, [0.25, 1.0]);
    });

    test('observedBy shares the token and notifies both listeners', () {
      final outer = <double>[];
      final inner = <double>[];
      final context = TaskContext(onProgress: outer.add);

      final observed = context.observedBy(inner.add)..reportProgress(1, 2);

      expect(outer, [0.5]);
      expect(inner, [0.5]);

      context.token.cancel();
      expect(observed.isCancelled, isTrue);
    });
  });

  group('TaskManager cancellation and progress', () {
    late TaskManager manager;

    setUp(() => manager = TaskManager());
    tearDown(() => manager.dispose());

    test('a queued task is dropped without running', () async {
      final blocker = Completer<void>();
      var secondRan = false;

      final first = manager.submit(
        id: 'first',
        title: 'first',
        operation: (_) => blocker.future,
      );
      final second = manager.submit(
        id: 'second',
        title: 'second',
        operation: (_) async => secondRan = true,
      );

      manager.cancel('second');

      await expectLater(second, throwsA(isA<CancelledFailure>()));

      blocker.complete();
      await first;

      expect(secondRan, isFalse);
      expect(
        manager.currentTasks.firstWhere((t) => t.id == 'second').status,
        TaskStatus.cancelled,
      );
    });

    test('a running task sees the cancellation and stops', () async {
      final started = Completer<void>();
      final resume = Completer<void>();

      final future = manager.submit(
        id: 'job',
        title: 'job',
        operation: (context) async {
          started.complete();
          await resume.future;
          context.throwIfCancelled();
        },
      );

      await started.future;
      manager.cancel('job');
      resume.complete();

      await expectLater(future, throwsA(isA<CancelledFailure>()));
      expect(manager.currentTasks.single.status, TaskStatus.cancelled);
    });

    test('progress reported by the operation is published', () async {
      final progress = <double?>[];
      final subscription = manager.tasks.listen(
        (tasks) => progress.add(tasks.single.progress),
      );

      await manager.submit(
        id: 'job',
        title: 'job',
        operation: (context) async {
          context
            ..reportProgress(1, 2)
            ..reportProgress(2, 2);
        },
      );
      await pumpEventQueue();

      expect(progress, containsAllInOrder([0.5, 1.0]));

      await subscription.cancel();
    });

    test('cancelling an unknown task is ignored', () {
      expect(() => manager.cancel('nope'), returnsNormally);
    });
  });
}
