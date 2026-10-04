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

  getIt.registerLazySingleton<ExtractPdfEngine>(
    () => ExtractPdfEngine()
  );

  getIt.registerLazySingleton<RotatePdfEngine>(
    () => RotatePdfEngine()
  );

  getIt.registerLazySingleton<PdfToImageEngine>(
    () => PdfToImageEngine()
  );

  getIt.registerLazySingleton<ImageToPdfEngine>(
    () => ImageToPdfEngine()
  );

  getIt.registerLazySingleton<EncryptPdfEngine>(
    () => EncryptPdfEngine()
  );

  getIt.registerLazySingleton<DecryptPdfEngine>(
    () => DecryptPdfEngine()
  );

  getIt.registerLazySingleton<CompressPdfEngine>(
    () => CompressPdfEngine()
  );
}