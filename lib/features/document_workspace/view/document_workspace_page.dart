import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../bloc/bloc.dart';
import 'document_workspace_view.dart';
import 'document_workspace_view_model.dart';

class DocumentWorkspacePage extends StatelessWidget {
  DocumentWorkspacePage({required this.document, super.key})
    : _engine = getIt<DocumentEngineFactory>().create(document);

  final Document document;
  final DocumentEngine _engine;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DocumentWorkspaceBloc>(param1: _engine)
            ..add(const DocumentWorkspaceStarted()),
      child: BlocBuilder<DocumentWorkspaceBloc, DocumentWorkspaceState>(
        builder: (context, state) {
          return switch (state) {
            DocumentWorkspaceInitial() => const Center(
              child: CircularProgressIndicator(),
            ),

            DocumentWorkspaceOpening(:final initialPageNumber) =>
              _DocumentWorkspaceHost(
                engine: _engine,
                initialPageNumber: initialPageNumber,
              ),

            DocumentWorkspaceLoaded() => _DocumentWorkspaceHost(
              engine: _engine,
              initialPageNumber: null,
            ),

            DocumentWorkspaceError(:final message) => Center(
              child: Text(message),
            ),
          };
        },
      ),
    );
  }
}

class _DocumentWorkspaceHost extends StatefulWidget {
  const _DocumentWorkspaceHost({
    required this.engine,
    required this.initialPageNumber,
  });

  final DocumentEngine engine;
  final int? initialPageNumber;

  @override
  State<_DocumentWorkspaceHost> createState() => _DocumentWorkspaceHostState();
}

class _DocumentWorkspaceHostState extends State<_DocumentWorkspaceHost> {
  Widget? _documentViewer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _documentViewer ??= widget.engine.buildViewer(
      config: DocumentEngineConfig(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        passwordProvider: () => showPasswordDialog(context: context),
        initialPageNumber: widget.initialPageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentViewer = _documentViewer!;

    return BlocBuilder<DocumentWorkspaceBloc, DocumentWorkspaceState>(
      builder: (context, state) {
        return switch (state) {
          DocumentWorkspaceOpening() => Stack(
            fit: StackFit.expand,
            children: [
              documentViewer,
              const Center(child: CircularProgressIndicator()),
            ],
          ),

          DocumentWorkspaceLoaded() => DocumentWorkspaceView(
            viewModel: DocumentWorkspaceViewModel(
              currentPage: state.currentPage,
              pageCount: state.pageCount,
              currentZoom: state.currentZoom,
              selectedTool: state.selectedTool,
              selectedPanel: state.selectedPanel,
              capabilities: widget.engine.capabilities,
              documentViewer: documentViewer,
              searchState: state.searchState,
              bookmarks: state.bookmarks,
              annotations: state.annotations,
              dictionaryState: state.dictionaryState,
              onToolSelected: (tool) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceToolSelected(tool),
                );
              },
              onPanelSelected: (panel) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspacePanelSelected(panel),
                );
              },
              onPanelClosed: () {
                context.read<DocumentWorkspaceBloc>().add(
                  const DocumentWorkspacePanelClosed(),
                );
              },
              onGotoPage: widget.engine.actions.goToPage,
              zoomIn: widget.engine.actions.zoomIn,
              zoomOut: widget.engine.actions.zoomOut,
              onTextSearch: (text, caseInsensitive) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceSearch(text, caseInsensitive),
                );
              },
              onClearSearch: () {
                context.read<DocumentWorkspaceBloc>().add(
                  const DocumentWorkspaceClearSearch(),
                );
              },
              onTextSearchResultSelected: (result) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceSelectSearch(result),
                );
              },
              onBookmarkSelected: (bookmark) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceSelectBookmark(bookmark),
                );
              },
              onAnnotationSelected: (annotation) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceSelectAnnotation(annotation),
                );
              },
              onDictionaryLookup: (word) {
                context.read<DocumentWorkspaceBloc>().add(
                  DocumentWorkspaceDictionaryLookup(word),
                );
              },
              onClearDictionary: () {
                context.read<DocumentWorkspaceBloc>().add(
                  const DocumentWorkspaceClearDictionary(),
                );
              },
            ),
          ),

          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
