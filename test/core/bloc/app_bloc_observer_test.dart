import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:velin/core/bloc/bloc.dart';

class _FailingCubit extends Cubit<int> {
  _FailingCubit() : super(0);

  void fail(Object error) => addError(error, StackTrace.current);
}

void main() {
  late BlocObserver originalObserver;
  late List<LogRecord> records;
  late StreamSubscription<LogRecord> subscription;

  setUp(() {
    originalObserver = Bloc.observer;
    Logger.root.level = Level.ALL;
    records = [];
    subscription = Logger.root.onRecord.listen(records.add);
  });

  tearDown(() async {
    Bloc.observer = originalObserver;
    await subscription.cancel();
  });

  test('logs bloc errors as severe with the bloc type', () async {
    Bloc.observer = AppBlocObserver();

    final cubit = _FailingCubit();
    final error = StateError('boom');

    cubit.fail(error);

    expect(records.single.level, Level.SEVERE);
    expect(records.single.loggerName, 'velin.bloc');
    expect(records.single.message, contains('_FailingCubit'));
    expect(records.single.error, same(error));

    await cubit.close();
  });
}
