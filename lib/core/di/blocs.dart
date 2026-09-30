import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/bloc/document_workspace_bloc.dart';
import 'package:velin/features/reader/reader.dart';

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
}