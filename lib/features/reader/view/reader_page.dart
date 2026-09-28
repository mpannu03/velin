import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/reader/bloc/bloc.dart';

import 'reader_view.dart';
import 'reader_view_model.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReaderBloc>()..add(const ReaderStarted()),
      child: BlocBuilder<ReaderBloc, ReaderState>(
        builder: (context, state) {
          return switch (state) {
            ReaderInitial() || ReaderLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ReaderLoaded() => ReaderView(
                viewModel: _createViewModel(context, state),
              ),
            ReaderError(:final message) => Center(
                child: Text(message),
              ),
          };
        },
      ),
    );
  }

  ReaderViewModel _createViewModel(
    BuildContext context,
    ReaderLoaded state,
  ) {
    final bloc = context.read<ReaderBloc>();

    return ReaderViewModel(
      documents: state.documents,
      selectedDocument: state.selectedDocument,
      onOpenDocument: () {
        bloc.add(const ReaderDocumentOpened());
      },
      onDocumentSelected: (document) {
        bloc.add(ReaderDocumentSelected(document));
      },
      onDocumentClosed: (document) {
        bloc.add(ReaderDocumentClosed(document));
      },
    );
  }
}