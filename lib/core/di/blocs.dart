import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/document_workspace/bloc/document_workspace_bloc.dart';
import 'package:velin/features/home/home.dart';
import 'package:velin/features/reader/reader.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/services/dictionary/dictionary.dart';

void registerBlocDependencies() {
  getIt.registerFactory<ReaderBloc>(
    () => ReaderBloc(
      documentService: getIt<DocumentService>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<DocumentWorkspaceBloc, DocumentEngine, void>(
    (engine, _) => DocumentWorkspaceBloc(
      engine: engine,
      recentDocumentService: getIt<RecentDocumentService>(),
      dictionaryService: getIt<DictionaryService>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<MergePdfCubit>(
    () => MergePdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      mergePdfEngine: getIt<MergePdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<SplitPdfCubit>(
    () => SplitPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      splitPdfEngine: getIt<SplitPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<ExtractPdfCubit>(
    () => ExtractPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      extractPdfEngine: getIt<ExtractPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<RotatePdfCubit>(
    () => RotatePdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      rotatePdfEngine: getIt<RotatePdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<PdfToImageCubit>(
    () => PdfToImageCubit(
      filePicker: getIt<DocumentFilePicker>(),
      pdfToImageEngine: getIt<PdfToImageEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<ImageToPdfCubit>(
    () => ImageToPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      imageToPdfEngine: getIt<ImageToPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<EncryptPdfCubit>(
    () => EncryptPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      encryptPdfEngine: getIt<EncryptPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<DecryptPdfCubit>(
    () => DecryptPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      decryptPdfEngine: getIt<DecryptPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<CompressPdfCubit>(
    () => CompressPdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      compressPdfEngine: getIt<CompressPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<AddWatermarkCubit>(
    () => AddWatermarkCubit(
      filePicker: getIt<DocumentFilePicker>(),
      addWatermarkEngine: getIt<AddWatermarkEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      recentDocumentService: getIt<RecentDocumentService>(),
      documentService: getIt<DocumentService>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );
}
