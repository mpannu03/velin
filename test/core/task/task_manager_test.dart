import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/task/task.dart';

void main() {
  late TaskManager taskManager;

  setUp(() {
    taskManager = TaskManager();
  });

  tearDown(() async {
    await taskManager.dispose();
  });

  test('submits a task as queued and then completes it', () async {
    final states = <List<AppTask>>[];

    final subscription = taskManager.tasks.listen(states.add);

    taskManager.submit(
      id: 'task-1',
      title: 'Merge PDF',
      operation: () async {},
    );

    await _waitUntil(
      () => taskManager.currentTasks.single.status == TaskStatus.completed,
    );

    expect(
      states.last.single.status,
      TaskStatus.completed,
    );

    await subscription.cancel();
  });

  test('marks a failed task as failed', () async {
    taskManager.submit(
      id: 'task-1',
      title: 'Merge PDF',
      operation: () async {
        throw Exception('Something went wrong');
      },
    );

    await _waitUntil(
      () => taskManager.currentTasks.single.status == TaskStatus.failed,
    );

    final task = taskManager.currentTasks.single;

    expect(task.status, TaskStatus.failed);
    expect(task.error, isA<Exception>());
  });

  test('runs tasks sequentially', () async {
    final events = <String>[];

    final firstCompleter = Completer<void>();

    taskManager.submit(
      id: 'task-1',
      title: 'Task 1',
      operation: () async {
        events.add('task-1-started');
        await firstCompleter.future;
        events.add('task-1-finished');
      },
    );

    taskManager.submit(
      id: 'task-2',
      title: 'Task 2',
      operation: () async {
        events.add('task-2-started');
        events.add('task-2-finished');
      },
    );

    await _waitUntil(
      () => events.contains('task-1-started'),
    );

    expect(events, ['task-1-started']);

    firstCompleter.complete();

    await _waitUntil(
      () => events.contains('task-2-finished'),
    );

    expect(
      events,
      [
        'task-1-started',
        'task-1-finished',
        'task-2-started',
        'task-2-finished',
      ],
    );
  });

  test('continues with the next task after a failure', () async {
    final events = <String>[];

    taskManager.submit(
      id: 'task-1',
      title: 'Task 1',
      operation: () async {
        events.add('task-1');
        throw Exception('Failed');
      },
    );

    taskManager.submit(
      id: 'task-2',
      title: 'Task 2',
      operation: () async {
        events.add('task-2');
      },
    );

    await _waitUntil(
      () => taskManager.currentTasks
          .every((task) => task.status == TaskStatus.failed ||
              task.status == TaskStatus.completed),
    );

    expect(events, ['task-1', 'task-2']);

    expect(
      taskManager.currentTasks[0].status,
      TaskStatus.failed,
    );

    expect(
      taskManager.currentTasks[1].status,
      TaskStatus.completed,
    );
  });

  test('emits task state changes', () async {
    final states = <TaskStatus>[];

    final subscription = taskManager.tasks.listen(
      (tasks) {
        states.add(tasks.single.status);
      },
    );

    taskManager.submit(
      id: 'task-1',
      title: 'Merge PDF',
      operation: () async {},
    );

    await _waitUntil(
      () => states.contains(TaskStatus.completed),
    );

    expect(
      states,
      [
        TaskStatus.queued,
        TaskStatus.running,
        TaskStatus.completed,
      ],
    );

    await subscription.cancel();
  });
}

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met');
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 10),
    );
  }
}