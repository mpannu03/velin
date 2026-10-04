import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/document_workspace/bloc/document_workspace_bloc.dart';
import 'package:velin/features/reader/reader.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

void registerBlocDependencies() {
  getIt.registerFactory<ReaderBloc>(
    () => ReaderBloc(
      documentService: getIt<DocumentService>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<DocumentWorkspaceBloc, DocumentEngine, void>(
    (engine, _) => DocumentWorkspaceBloc(engine: engine),
  );

  getIt.registerFactoryParam<MergePdfCubit, AppLocalizations, void>(
    (l10n, _) => MergePdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      mergePdfEngine: getIt<MergePdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<SplitPdfCubit, AppLocalizations, void>(
    (l10n, _) => SplitPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      splitPdfEngine: getIt<SplitPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<ExtractPdfCubit, AppLocalizations, void>(
    (l10n, _) => ExtractPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      extractPdfEngine: getIt<ExtractPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<RotatePdfCubit, AppLocalizations, void>(
    (l10n, _) => RotatePdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      rotatePdfEngine: getIt<RotatePdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<PdfToImageCubit, AppLocalizations, void>(
    (l10n, _) => PdfToImageCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      pdfToImageEngine: getIt<PdfToImageEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<ImageToPdfCubit, AppLocalizations, void>(
    (l10n, _) => ImageToPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      imageToPdfEngine: getIt<ImageToPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<EncryptPdfCubit, AppLocalizations, void>(
    (l10n, _) => EncryptPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      encryptPdfEngine: getIt<EncryptPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<DecryptPdfCubit, AppLocalizations, void>(
    (l10n, _) => DecryptPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      decryptPdfEngine: getIt<DecryptPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );

  getIt.registerFactoryParam<CompressPdfCubit, AppLocalizations, void>(
    (l10n, _) => CompressPdfCubit(
      l10n: l10n,
      filePicker: getIt<DocumentFilePicker>(),
      compressPdfEngine: getIt<CompressPdfEngine>(),
      taskManager: getIt<TaskManager>(),
      appEffectController: getIt<AppEffectController>(),
    ),
  );
}
