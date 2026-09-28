import 'package:velin/core/file/file_picker.dart';
import 'package:velin/data/file/file_picker_impl.dart';

import 'injection.dart';

void registerCoreDependencies() {
  getIt.registerLazySingleton<DocumentFilePicker>(
    () => DocumentFilePickerImpl()
  );
}