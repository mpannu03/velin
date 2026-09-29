import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/data/file/file_picker_impl.dart';
import 'package:velin/engine/document_engine_factory.dart';

import 'injection.dart';

void registerCoreDependencies() {
  getIt.registerLazySingleton<DocumentFilePicker>(
    () => DocumentFilePickerImpl()
  );

  getIt.registerLazySingleton<AppEffectController>(
    () => AppEffectController()
  );

  getIt.registerLazySingleton<DocumentEngineFactory>(
    () => DocumentEngineFactory()
  );
}