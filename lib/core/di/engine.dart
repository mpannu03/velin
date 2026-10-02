import 'package:velin/core/di/injection.dart';
import 'package:velin/engine/engine.dart';

void registerEngineDependencies() {
  getIt.registerLazySingleton<DocumentEngineFactory>(
    () => DocumentEngineFactory()
  );

  getIt.registerLazySingleton<MergePdfEngine>(
    () => MergePdfEngine()
  );

  getIt.registerLazySingleton<SplitPdfEngine>(
    () => SplitPdfEngine()
  );
}