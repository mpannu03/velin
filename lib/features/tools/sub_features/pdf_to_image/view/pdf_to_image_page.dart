import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PdfToImageCubit>(param1: context.l10n),
      child: const _PdfToImagePageContent(),
    );
  }
}

class _PdfToImagePageContent extends StatelessWidget {
  const _PdfToImagePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfToImageCubit, PdfToImageState>(
      builder: (context, state) {
        return PdfToImageView(viewModel: _buildViewModel(context, state));
      },
    );
  }

  PdfToImageViewModel _buildViewModel(
    BuildContext context,
    PdfToImageState state,
  ) {
    final cubit = context.read<PdfToImageCubit>();

    return PdfToImageViewModel(
      inputFilePath: state.inputFilePath,
      scope: state.scope,
      selection: state.selection,
      format: state.format,
      colorMode: state.colorMode,
      dpi: state.dpi,
      quality: state.quality,
      supportsQuality: state.supportsQuality,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      canConvert: state.canConvert,
      onPickFile: cubit.pickFile,
      onScopeChanged: cubit.changeScope,
      onSelectionChanged: cubit.updateSelection,
      onFormatChanged: cubit.changeFormat,
      onColorModeChanged: cubit.changeColorMode,
      onDpiChanged: cubit.changeDpi,
      onQualityChanged: cubit.changeQuality,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onConvert: cubit.convert,
      onBack: context.pop,
    );
  }
}
