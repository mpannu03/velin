import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/bloc/tool_task_handle.dart';

void main() {
  late ToolTaskHandle handle;

  setUp(() => handle = ToolTaskHandle());

  test('starts idle and cannot be cancelled', () {
    var cancelled = false;

    expect(handle.status.value, ToolTaskStatus.idle);

    handle.cancel();

    expect(cancelled, isFalse);
  });

  test('moves through queued, running with progress, and back to idle', () {
    final seen = <ToolTaskStatus>[];
    handle.status.addListener(() => seen.add(handle.status.value));

    handle
      ..queued(cancel: () {})
      ..running()
      ..running(0.5)
      ..finished();

    expect(seen, [
      ToolTaskStatus.queued,
      const ToolTaskStatus.running(),
      const ToolTaskStatus.running(0.5),
      ToolTaskStatus.idle,
    ]);
  });

  test(
    'cancel calls the task cancel callback once and ignores late progress',
    () {
      var calls = 0;

      handle
        ..queued(cancel: () => calls++)
        ..running(0.2)
        ..cancel()
        ..cancel()
        ..running(0.9);

      expect(calls, 1);
      expect(handle.status.value.phase, ToolTaskPhase.cancelling);
      expect(handle.status.value.progress, 0.2);
      expect(handle.status.value.canCancel, isFalse);
    },
  );

  test('ignores updates after dispose', () {
    handle.dispose();

    expect(
      () => handle
        ..queued(cancel: () {})
        ..running(0.5),
      returnsNormally,
    );
    expect(handle.dispose, returnsNormally);
  });
}
