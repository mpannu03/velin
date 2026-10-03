import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ImageToPdfPage extends StatelessWidget {
  const ImageToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ImageToPdfCubit>(param1: context.l10n),
      child: const _ImageToPdfPageContent(),
    );
  }
}

class _ImageToPdfPageContent extends StatelessWidget {
  const _ImageToPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageToPdfCubit, ImageToPdfState>(
      builder: (context, state) {
        return ImageToPdfView(
          viewModel: _buildViewModel(
            context,
            state,
          ),
        );
      },
    );
  }

  ImageToPdfViewModel _buildViewModel(
    BuildContext context,
    ImageToPdfState state,
  ) {
    final cubit = context.read<ImageToPdfCubit>();

    return ImageToPdfViewModel(
      inputs: state.inputs,
      viewMode: state.viewMode,
      pageSize: state.pageSize,
      orientation: state.orientation,
      fit: state.fit,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      isSubmitting: state.isSubmitting,
      canConvert: state.canConvert,
      onAddImages: cubit.pickImages,
      onRemoveImage: cubit.removeImage,
      onReorder: cubit.reorderImages,
      onViewModeChanged: cubit.changeViewMode,
      onPageSizeChanged: cubit.changePageSize,
      onOrientationChanged: cubit.changeOrientation,
      onFitChanged: cubit.changeFit,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onConvert: cubit.convert,
      onBack: context.pop,
    );
  }
}
