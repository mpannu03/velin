import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/data/file/file_picker_impl.dart';

import 'injection.dart';

void registerCoreDependencies() {
  getIt.registerLazySingleton<DocumentFilePicker>(
    () => DocumentFilePickerImpl()
  );

  getIt.registerLazySingleton<AppEffectController>(
    () => AppEffectController()
  );

  getIt.registerLazySingleton<TaskManager>(
    () => TaskManager()
  );

  getIt.registerLazySingleton<Pdf>(
    () => Pdf()
  );
}