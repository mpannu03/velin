import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/app_info/app_info.dart';
import 'package:velin/core/bloc/bloc.dart';
import 'package:velin/core/di/injection.dart' as di;
import 'package:velin/core/error/global_error_handlers.dart';
import 'package:velin/core/logging/logging.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging and the error safety net come first so that anything failing
  // during startup is recorded.
  final logging = await AppLogging.initialize();
  installGlobalErrorHandlers();
  Bloc.observer = AppBlocObserver();

  final appInfo = await AppInfo.load();

  Logger('velin.main').info(
    'Starting Velin ${appInfo.displayVersion} '
    '(${kReleaseMode ? 'release' : 'debug'}) on '
    '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
  );

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  pdfrxFlutterInitialize();

  di.configureDependencies(logging: logging, appInfo: appInfo);

  runApp(const VelinApp());
}
