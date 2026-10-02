import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';


class MergePdfPage extends StatelessWidget {
  const MergePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MergePdfCubit>()..started(),
      child: const _MergePdfPageContent(),
    );
  }
}

class _MergePdfPageContent extends StatelessWidget {
  const _MergePdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MergePdfCubit, MergePdfState>(
      builder: (context, state) {
        return switch (state) {
          MergePdfInitial() => const SizedBox.shrink(),
          MergePdfReady() => MergePdfView(
              viewModel: _buildViewModel(
                context,
                state,
              ),
            ),
          MergePdfError(:final error) => Center(
              child: Text(error.toString()),
            ),
        };
      },
    );
  }

  MergePdfViewModel _buildViewModel(
    BuildContext context,
    MergePdfReady state,
  ) {
    final cubit = context.read<MergePdfCubit>();

    return MergePdfViewModel(
      inputs: state.inputs,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      onAddFiles: cubit.pickFiles,
      onRemoveFile: cubit.removeFile,
      onReorder: cubit.reorderFiles,
      onPageSelectionChanged: cubit.updatePageSelection,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onMerge: cubit.merge,
    );
  }
}
