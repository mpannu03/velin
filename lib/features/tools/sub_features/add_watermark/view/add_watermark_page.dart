import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class AddWatermarkPage extends StatelessWidget {
  const AddWatermarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddWatermarkCubit>(param1: context.l10n),
      child: const _AddWatermarkPageContent(),
    );
  }
}

class _AddWatermarkPageContent extends StatelessWidget {
  const _AddWatermarkPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddWatermarkCubit, AddWatermarkState>(
      builder: (context, state) {
        return AddWatermarkView(
          viewModel: _buildViewModel(context, state),
        );
      },
    );
  }

  AddWatermarkViewModel _buildViewModel(
    BuildContext context,
    AddWatermarkState state,
  ) {
    final cubit = context.read<AddWatermarkCubit>();

    return AddWatermarkViewModel(
      inputFilePath: state.inputFilePath,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      type: state.type,
      text: state.text,
      imageFilePath: state.imageFilePath,
      fontName: state.fontName,
      fontSize: state.fontSize,
      colorHex: state.colorHex,
      opacity: state.opacity,
      rotation: state.rotation,
      position: state.position,
      xOffset: state.xOffset,
      yOffset: state.yOffset,
      imageWidthPercent: state.imageWidthPercent,
      layer: state.layer,
      scope: state.scope,
      selection: state.selection,
      isSubmitting: state.isSubmitting,
      canApplyWatermark: state.canApplyWatermark,
      onPickFile: cubit.pickFile,
      onPickWatermarkImage: cubit.pickWatermarkImage,
      onClearWatermarkImage: cubit.clearWatermarkImage,
      onTypeChanged: cubit.changeType,
      onTextChanged: cubit.updateText,
      onFontNameChanged: cubit.changeFontName,
      onFontSizeChanged: cubit.changeFontSize,
      onColorHexChanged: cubit.changeColorHex,
      onOpacityChanged: cubit.changeOpacity,
      onRotationChanged: cubit.changeRotation,
      onPositionChanged: cubit.changePosition,
      onXOffsetChanged: cubit.changeXOffset,
      onYOffsetChanged: cubit.changeYOffset,
      onImageWidthPercentChanged: cubit.changeImageWidthPercent,
      onLayerChanged: cubit.changeLayer,
      onScopeChanged: cubit.changeScope,
      onSelectionChanged: cubit.updateSelection,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onApplyWatermark: cubit.applyWatermark,
      onBack: context.pop,
    );
  }
}