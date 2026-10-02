import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class SplitPdfPage extends StatelessWidget {
  const SplitPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplitPdfCubit>(param1: context.l10n),
      child: const _SplitPdfPageContent(),
    );
  }
}

class _SplitPdfPageContent extends StatelessWidget {
  const _SplitPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplitPdfCubit, SplitPdfState>(
      builder: (context, state) {
        return SplitPdfView(
          viewModel: _buildViewModel(
            context,
            state,
          ),
        );
      },
    );
  }

  SplitPdfViewModel _buildViewModel(
    BuildContext context,
    SplitPdfState state,
  ) {
    final cubit = context.read<SplitPdfCubit>();

    return SplitPdfViewModel(
      inputFilePath: state.inputFilePath,
      mode: state.mode,
      selections: state.selections,
      pageCount: state.pageCount,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      canSplit: state.canSplit,
      onPickFile: cubit.pickFile,
      onModeChanged: cubit.changeMode,
      onPageCountChanged: cubit.updatePageCount,
      onAddSelection: cubit.addSelection,
      onSelectionChanged: cubit.updateSelection,
      onRemoveSelection: cubit.removeSelection,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onSplit: cubit.split,
    );
  }
}
