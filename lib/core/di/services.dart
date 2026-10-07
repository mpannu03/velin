import 'package:http/http.dart' as http;
import 'package:velin/core/document/document.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/data/document/document.dart';
import 'package:velin/engine/rendering/rendering.dart';
import 'package:velin/services/dictionary/dictionary.dart';

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
}
