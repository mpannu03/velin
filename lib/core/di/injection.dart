import 'package:get_it/get_it.dart';

import 'core.dart';
import 'repositories.dart';
import 'services.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  registerCoreDependencies();
  registerRepositoryDependencies();
  registerServiceDependencies();
}