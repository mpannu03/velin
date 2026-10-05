import 'package:velin/core/document/document.dart';
import 'package:velin/data/document/document.dart';

import 'injection.dart';

void registerRepositoryDependencies() {
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(),
    dispose: (repository) => (repository as DocumentRepositoryImpl).dispose(),
  );
}
