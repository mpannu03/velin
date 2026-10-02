import 'package:get_it/get_it.dart';
import 'package:velin/core/di/blocs.dart';

import 'core.dart';
import 'engine.dart';
import 'repositories.dart';
import 'services.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  registerCoreDependencies();
  registerEngineDependencies();
  registerRepositoryDependencies();
  registerServiceDependencies();
  registerBlocDependencies();
}