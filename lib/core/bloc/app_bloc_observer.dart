import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

/// Logs errors raised inside any bloc or cubit, including exceptions thrown by
/// event handlers that the handler itself did not catch.
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({Logger? logger}) : _log = logger ?? Logger('velin.bloc');

  final Logger _log;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log.severe('Unhandled error in ${bloc.runtimeType}', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
