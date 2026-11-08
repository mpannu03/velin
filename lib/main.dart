import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:velin/app/commands/commands.dart';
import 'package:velin/core/app_info/app_info.dart';
import 'package:velin/core/bloc/bloc.dart';
import 'package:velin/core/di/injection.dart' as di;
import 'package:velin/core/error/global_error_handlers.dart';
import 'package:velin/core/logging/logging.dart';
import 'package:velin/core/platform/open_files_channel.dart';
import 'package:velin/core/window/window_placement.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';

final _log = Logger('velin.main');

/// [arguments] holds the files to open when Velin is started with them,
/// e.g. by "Open with Velin" or `velin file.pdf`.
void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging and the error safety net come first so that anything failing
  // during startup is recorded.
  final logging = await AppLogging.initialize();
  installGlobalErrorHandlers();
  Bloc.observer = AppBlocObserver();

  final appInfo = await AppInfo.load();

  _log.info(
    'Starting Velin ${appInfo.displayVersion} '
    '(${kReleaseMode ? 'release' : 'debug'}) on '
    '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
  );

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      minimumSize: Size(720, 480),
    );

    final placementKeeper = await _createPlacementKeeper();

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await placementKeeper?.restore();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  pdfrxFlutterInitialize();

  di.configureDependencies(logging: logging, appInfo: appInfo);

  runApp(const VelinApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final handler = di.getIt<AppCommandHandler>();

    handler.openPaths(filePathsFromArguments(arguments));
    OpenFilesChannel().listen(handler.openPaths);
  });
}

Future<WindowPlacementKeeper?> _createPlacementKeeper() async {
  try {
    final support = await getApplicationSupportDirectory();

    return WindowPlacementKeeper(
      store: WindowPlacementStore(File(p.join(support.path, 'window.json'))),
      windowManager: windowManager,
      displays: () async => [
        for (final display in await screenRetriever.getAllDisplays())
          (display.visiblePosition ?? Offset.zero) &
              (display.visibleSize ?? display.size),
      ],
    );
  } catch (error, stackTrace) {
    // Remembering the window position is a nicety; never block startup.
    _log.warning('Window placement disabled', error, stackTrace);
    return null;
  }
}
