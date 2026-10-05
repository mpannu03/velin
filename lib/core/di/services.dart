import 'package:velin/core/document/document.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/data/document/document.dart';

import 'injection.dart';

void registerServiceDependencies() {
  getIt.registerLazySingleton<DocumentService>(
    () => DocumentServiceImpl(
      filePicker: getIt<DocumentFilePicker>(),
      documentRepository: getIt<DocumentRepository>(),
    ),
  );
}
