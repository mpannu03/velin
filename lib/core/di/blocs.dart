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

  getIt.registerFactory<MergePdfCubit>(
    () => MergePdfCubit(
      filePicker: getIt<DocumentFilePicker>(),
      mergePdfEngine: getIt<MergePdfEngine>(),
      taskManager: getIt<TaskManager>(),
    ),
  );
}