import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/data/document/document.dart';
import 'package:velin/data/recent/recent.dart';

import 'injection.dart';

void registerRepositoryDependencies() {
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(),
    dispose: (repository) => (repository as DocumentRepositoryImpl).dispose(),
  );

  getIt.registerLazySingleton<RecentDocumentRepository>(
    () => DriftRecentDocumentRepository(getIt<RecentDatabase>()),
  );

  getIt.registerLazySingleton<ThumbnailRepository>(
    () => FileThumbnailRepository(),
  );
}
