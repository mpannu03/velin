import 'dart:isolate';

/// Runs `function(argument)` on a short-lived background isolate and returns
/// its result.
///
/// Use this instead of `Isolate.run(() => ...)` with an inline closure. A
/// closure written inside an `async` method can capture that method's whole
/// local context, including pdfium documents and other native handles that
/// cannot be sent between isolates. That fails at runtime with "Illegal
/// argument in isolate message". Here the closure is created in this
/// synchronous function, so it captures only [function] and [argument].
///
/// [function] must be a top-level or static function, and [argument] must be
/// sendable (primitives, typed data, records and plain objects of those).
Future<R> runInBackground<A, R>(R Function(A argument) function, A argument) {
  return Isolate.run(() => function(argument));
}
