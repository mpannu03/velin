import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ExtractPdfPage extends StatelessWidget {
  const ExtractPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExtractPdfCubit>(param1: context.l10n),
      child: const _ExtractPdfPageContent(),
    );
  }
}

class _ExtractPdfPageContent extends StatelessWidget {
  const _ExtractPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtractPdfCubit, ExtractPdfState>(
      builder: (context, state) {
        return ExtractPdfView(
          viewModel: _buildViewModel(
            context,
            state,
          ),
        );
      },
    );
  }

  ExtractPdfViewModel _buildViewModel(
    BuildContext context,
    ExtractPdfState state,
  ) {
    final cubit = context.read<ExtractPdfCubit>();

    return ExtractPdfViewModel(
      inputFilePath: state.filePath,
      pageSelection: state.pageSelection,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      canExtract: state.canExtract,
      onPickFile: cubit.pickFile,
      onSelectionChanged: cubit.updateSelection,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onExtract: cubit.extract,
      onBack: context.pop,
    );
  }
}