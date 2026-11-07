import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:velin/core/error/global_error_handlers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? originalFlutterHandler;
  late ErrorCallback? originalPlatformHandler;
  late List<LogRecord> records;
  late StreamSubscription<LogRecord> subscription;

  setUp(() {
    originalFlutterHandler = FlutterError.onError;
    originalPlatformHandler = PlatformDispatcher.instance.onError;

    Logger.root.level = Level.ALL;
    records = [];
    subscription = Logger.root.onRecord.listen(records.add);
  });

  tearDown(() async {
    FlutterError.onError = originalFlutterHandler;
    PlatformDispatcher.instance.onError = originalPlatformHandler;
    await subscription.cancel();
  });

  test('logs framework errors and still calls the previous handler', () {
    FlutterErrorDetails? forwarded;
    FlutterError.onError = (details) => forwarded = details;

    installGlobalErrorHandlers(replaceErrorWidget: false);

    final error = StateError('layout exploded');
    final details = FlutterErrorDetails(
      exception: error,
      stack: StackTrace.current,
    );

    FlutterError.onError!(details);

    expect(forwarded, same(details));
    expect(records.single.level, Level.SEVERE);
    expect(records.single.loggerName, 'velin.uncaught');
    expect(records.single.error, same(error));
  });

  test('logs uncaught async errors and marks them handled', () {
    PlatformDispatcher.instance.onError = null;

    installGlobalErrorHandlers(replaceErrorWidget: false);

    final error = Exception('lost future');
    final handled = PlatformDispatcher.instance.onError!(
      error,
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(records.single.level, Level.SEVERE);
    expect(records.single.error, same(error));
  });
}
