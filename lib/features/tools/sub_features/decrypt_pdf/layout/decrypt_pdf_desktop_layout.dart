import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class DecryptPdfDesktopLayout extends StatelessWidget {
  const DecryptPdfDesktopLayout({super.key, required this.viewModel});

  final DecryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsUnlockPdf,
      description: l10n.toolsUnlockIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsUnlockSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription:
                  l10n.toolsUnlockAlreadyProtectedDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsUnlockPasswordSectionTitle,
              child: _PasswordField(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutputFilePicker(
              fileName: viewModel.outputFileName,
              directoryPath: viewModel.outputDirectory,
              onFileNameChanged: viewModel.onOutputFileNameChanged,
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: AppSpacing.xl),
            ToolActionBar(
              isSubmitting: viewModel.isSubmitting,
              submittingText: l10n.toolsUnlockSubmitting,
              canAction: viewModel.canDecrypt,
              icon: Icons.lock_open_outlined,
              label: l10n.toolsUnlockButton,
              hintText: l10n.toolsUnlockButtonDisabledHint,
              onAction: viewModel.onUnlock,
            ),
          ],
        ],
      ),
    );
  }
}

/// An obscured text field that commits its value on submit and on focus loss.
///
/// The controller is owned here rather than driven by the view model so the
/// caret does not jump to the end on every keystroke.
class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.viewModel});

  final DecryptPdfViewModel viewModel;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.password);
  }

  @override
  void didUpdateWidget(covariant _PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final password = widget.viewModel.password;

    if (password != oldWidget.viewModel.password &&
        password != _controller.text) {
      _controller.text = password;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() => widget.viewModel.onPasswordChanged(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextField(
      key: const ValueKey('decrypt-password'),
      controller: _controller,
      obscureText: true,
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) => _commit(),
      decoration: InputDecoration(
        labelText: l10n.toolsUnlockPasswordLabel,
        helperText: l10n.toolsUnlockPasswordHelper,
        helperMaxLines: 2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
