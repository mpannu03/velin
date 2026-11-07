import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';

final _log = Logger('velin.uncaught');

/// Installs the app-wide safety net for errors nobody caught.
///
/// * Framework errors (build, layout, paint, gestures) go through
///   [FlutterError.onError]. The previous handler still runs, so debug builds
///   keep the usual console dump.
/// * Uncaught async errors on the root isolate go through
///   [PlatformDispatcher.onError].
/// * In release builds, a widget that fails to build renders a quiet
///   placeholder instead of the grey error box.
///
/// This is the last line of defence. Expected failures (missing file, wrong
/// password, ...) should be handled where they happen and turned into a
/// `Failure`; anything that ends up here is a bug and is logged as SEVERE.
void installGlobalErrorHandlers({bool replaceErrorWidget = kReleaseMode}) {
  final previousFlutterHandler = FlutterError.onError;

  FlutterError.onError = (details) {
    _log.severe(
      'Framework error: ${details.exceptionAsString()}'
      '${details.context != null ? ' (${details.context})' : ''}',
      details.exception,
      details.stack,
    );
    previousFlutterHandler?.call(details);
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _log.severe('Uncaught asynchronous error', error, stackTrace);
    previousPlatformHandler?.call(error, stackTrace);
    // Handled: keep the app running rather than letting the engine treat it
    // as fatal.
    return true;
  };

  if (replaceErrorWidget) {
    ErrorWidget.builder = (_) => const _BuildErrorPlaceholder();
  }
}

class _BuildErrorPlaceholder extends StatelessWidget {
  const _BuildErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Deliberately free of Theme, MediaQuery and localizations: this may be
    // rendered above MaterialApp, or because one of those failed.
    return const ColoredBox(
      color: Color(0x14808080),
      child: Center(
        child: Icon(
          Icons.error_outline,
          size: 24,
          color: Color(0xFF808080),
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
