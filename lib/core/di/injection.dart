import 'package:get_it/get_it.dart';
import 'package:velin/core/di/blocs.dart';
import 'package:velin/core/logging/logging.dart';

import 'core.dart';
import 'engine.dart';
import 'repositories.dart';
import 'services.dart';

final getIt = GetIt.instance;

void configureDependencies({required AppLogging logging}) {
  getIt.registerSingleton<AppLogging>(logging);

  registerCoreDependencies();
  registerEngineDependencies();
  registerRepositoryDependencies();
  registerServiceDependencies();
  registerBlocDependencies();
}
