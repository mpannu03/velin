import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class EncryptPdfPage extends StatelessWidget {
  const EncryptPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EncryptPdfCubit>(param1: context.l10n),
      child: const _EncryptPdfPageContent(),
    );
  }
}

class _EncryptPdfPageContent extends StatelessWidget {
  const _EncryptPdfPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptPdfCubit, EncryptPdfState>(
      builder: (context, state) {
        return EncryptPdfView(viewModel: _buildViewModel(context, state));
      },
    );
  }

  EncryptPdfViewModel _buildViewModel(
    BuildContext context,
    EncryptPdfState state,
  ) {
    final cubit = context.read<EncryptPdfCubit>();

    return EncryptPdfViewModel(
      inputFilePath: state.inputFilePath,
      outputFileName: state.outputFileName,
      outputDirectory: state.outputDirectory,
      userPassword: state.userPassword,
      ownerPassword: state.ownerPassword,
      level: state.level,
      permissions: state.permissions,
      isSubmitting: state.isSubmitting,
      canProtect: state.canProtect,
      onPickFile: cubit.pickFile,
      onUserPasswordChanged: cubit.updateUserPassword,
      onOwnerPasswordChanged: cubit.updateOwnerPassword,
      onLevelChanged: cubit.changeLevel,
      onPermissionsChanged: cubit.changePermissions,
      onOutputFileNameChanged: cubit.updateOutputFileName,
      onChooseOutputFolder: cubit.pickOutputDirectory,
      onProtect: cubit.protect,
      onBack: context.pop,
    );
  }
}
