import 'package:http/http.dart' as http;
import 'package:velin/app/commands/commands.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/app/navigation/app_router.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/logging/logging.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/data/document/document.dart';
import 'package:velin/engine/rendering/rendering.dart';
import 'package:velin/services/dictionary/dictionary.dart';
import 'package:window_manager/window_manager.dart';

import 'injection.dart';

void registerServiceDependencies() {
  getIt.registerLazySingleton<DocumentService>(
    () => DocumentServiceImpl(
      filePicker: getIt<DocumentFilePicker>(),
      documentRepository: getIt<DocumentRepository>(),
    ),
  );

  getIt.registerLazySingleton<RecentDocumentService>(
    () => RecentDocumentService(
      repository: getIt<RecentDocumentRepository>(),
      thumbnailRepository: getIt<ThumbnailRepository>(),
      pageRenderer: getIt<PdfPageRenderer>(),
    ),
  );

  getIt.registerLazySingleton<DictionaryService>(
    () => WiktionaryService(client: getIt<http.Client>()),
  );

  getIt.registerLazySingleton<AppCommandHandler>(
    () => AppCommandHandler(
      documentService: getIt<DocumentService>(),
      appEffectController: getIt<AppEffectController>(),
      navigate: (location) => AppRouter.router.go(location),
      windowManager: windowManager,
      logDirectory: getIt<AppLogging>().logDirectory,
    ),
  );
}
