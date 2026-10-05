import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/engine/engine.dart';

void registerEngineDependencies() {
  getIt.registerLazySingleton<DocumentEngineFactory>(
    () => DocumentEngineFactory(),
  );

  getIt.registerLazySingleton<MergePdfEngine>(() => MergePdfEngine());

  getIt.registerLazySingleton<SplitPdfEngine>(() => SplitPdfEngine());

  getIt.registerLazySingleton<ExtractPdfEngine>(() => ExtractPdfEngine());

  getIt.registerLazySingleton<RotatePdfEngine>(() => RotatePdfEngine());

  getIt.registerLazySingleton<PdfToImageEngine>(() => PdfToImageEngine());

  getIt.registerLazySingleton<ImageToPdfEngine>(() => ImageToPdfEngine());

  getIt.registerLazySingleton<EncryptPdfEngine>(
    () => EncryptPdfEngine(pdf: getIt<Pdf>()),
  );

  getIt.registerLazySingleton<DecryptPdfEngine>(
    () => DecryptPdfEngine(pdf: getIt<Pdf>()),
  );

  getIt.registerLazySingleton<CompressPdfEngine>(() => CompressPdfEngine());

  getIt.registerLazySingleton<AddWatermarkEngine>(
    () => AddWatermarkEngine(pdf: getIt<Pdf>()),
  );
}
