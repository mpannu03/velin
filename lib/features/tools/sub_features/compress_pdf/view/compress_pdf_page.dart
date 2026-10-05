import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class CompressPdfPage extends StatelessWidget {
  const CompressPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CompressPdfCubit>(param1: context.l10n),
      child: const _CompressPdfPageContent(),
    );
  }
}

class _CompressPdfPageContent extends StatelessWidget {
  const _CompressPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompressPdfCubit, CompressPdfState>(
      builder: (context, state) {
        return CompressPdfView(viewModel: _buildViewModel(context, state));
      },
    );
  }

  CompressPdfViewModel _buildViewModel(
    BuildContext context,
    CompressPdfState state,
  ) {
    final cubit = context.read<CompressPdfCubit>();

    return CompressPdfViewModel(
      inputFilePath: state.inputFilePath,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      quality: state.quality,
      isSubmitting: state.isSubmitting,
      canCompress: state.canCompress,
      onPickFile: cubit.pickFile,
      onQualityChanged: cubit.changeQuality,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onCompress: cubit.compress,
      onBack: context.pop,
    );
  }
}
