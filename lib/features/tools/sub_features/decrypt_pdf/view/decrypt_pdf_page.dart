import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class DecryptPdfPage extends StatelessWidget {
  const DecryptPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DecryptPdfCubit>(param1: context.l10n),
      child: const _DecryptPdfPageContent(),
    );
  }
}

class _DecryptPdfPageContent extends StatelessWidget {
  const _DecryptPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DecryptPdfCubit, DecryptPdfState>(
      builder: (context, state) {
        return DecryptPdfView(viewModel: _buildViewModel(context, state));
      },
    );
  }

  DecryptPdfViewModel _buildViewModel(
    BuildContext context,
    DecryptPdfState state,
  ) {
    final cubit = context.read<DecryptPdfCubit>();

    return DecryptPdfViewModel(
      inputFilePath: state.inputFilePath,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      password: state.password,
      isSubmitting: state.isSubmitting,
      canDecrypt: state.canDecrypt,
      onPickFile: cubit.pickFile,
      onPasswordChanged: cubit.updatePassword,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onUnlock: cubit.unlock,
      onBack: context.pop,
    );
  }
}
