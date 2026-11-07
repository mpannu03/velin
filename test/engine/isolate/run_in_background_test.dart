import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/engine/isolate/run_in_background.dart';

int _sum(List<int> values) => values.fold(0, (a, b) => a + b);

int _length((Uint8List, int) job) => job.$1.length + job.$2;

Never _fail(String _) => throw const CorruptDocumentFailure();

void main() {
  test('runs the function on another isolate and returns its result', () async {
    final callerIsolate = Isolate.current.hashCode;

    final ranOn = await runInBackground((_) => Isolate.current.hashCode, null);

    expect(ranOn, isNot(callerIsolate));
    expect(await runInBackground(_sum, [1, 2, 3]), 6);
  });

  test('ignores unsendable objects in the caller\'s scope', () async {
    // A ReceivePort cannot be sent to another isolate. An inline
    // Isolate.run closure in this async function could capture it; the
    // helper's closure cannot.
    final port = ReceivePort();
    addTearDown(port.close);

    final bytes = Uint8List(10);

    expect(await runInBackground(_length, (bytes, 5)), 15);
    expect(port, isNotNull);
  });

  test('rethrows a sendable error from the background isolate', () async {
    await expectLater(
      runInBackground(_fail, 'x'),
      throwsA(isA<CorruptDocumentFailure>()),
    );
  });
}
