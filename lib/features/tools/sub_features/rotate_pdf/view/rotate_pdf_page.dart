import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class RotatePdfPage extends StatelessWidget {
  const RotatePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RotatePdfCubit>(param1: context.l10n),
      child: const _RotatePdfPageContent(),
    );
  }
}

class _RotatePdfPageContent extends StatelessWidget {
  const _RotatePdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RotatePdfCubit, RotatePdfState>(
      builder: (context, state) {
        return RotatePdfView(
          viewModel: _buildViewModel(context, state),
        );
      },
    );
  }

  RotatePdfViewModel _buildViewModel(
    BuildContext context,
    RotatePdfState state,
  ) {
    final cubit = context.read<RotatePdfCubit>();

    return RotatePdfViewModel(
      inputFilePath: state.inputFilePath,
      direction: state.direction,
      scope: state.scope,
      selection: state.selection,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      canRotate: state.canRotate,
      onPickFile: cubit.pickFile,
      onDirectionChanged: cubit.changeDirection,
      onScopeChanged: cubit.changeScope,
      onSelectionChanged: cubit.updateSelection,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onRotate: cubit.rotate,
      onBack: context.pop,
    );
  }
}