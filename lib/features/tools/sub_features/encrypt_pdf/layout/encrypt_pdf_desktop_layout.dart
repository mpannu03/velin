import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class EncryptPdfDesktopLayout extends StatelessWidget {
  const EncryptPdfDesktopLayout({super.key, required this.viewModel});

  final EncryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile =
        viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsProtectPdf,
      description: l10n.toolsProtectIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsProtectSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription:
                  l10n.toolsProtectAlreadyProtectedDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsProtectPasswordSectionTitle,
              child: _PasswordEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsProtectSecuritySectionTitle,
              child: _SecurityEditor(viewModel: viewModel),
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
              submittingText: l10n.toolsProtectSubmitting,
              canAction: viewModel.canProtect,
              icon: Icons.lock_outline,
              label: l10n.toolsProtectButton,
              hintText: l10n.toolsProtectButtonDisabledHint,
              onAction: viewModel.onProtect,
            ),
          ],
        ],
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// An obscured text field that commits its value on submit and on focus loss.
///
/// The controller is owned here rather than driven by the view model so the
/// caret does not jump to the end on every keystroke.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.fieldKey,
    required this.value,
    required this.labelText,
    required this.helperText,
    required this.onChanged,
  });

  final Key fieldKey;
  final String value;
  final String labelText;
  final String helperText;
  final ValueChanged<String> onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() => widget.onChanged(_controller.text);

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.fieldKey,
      controller: _controller,
      obscureText: true,
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) => _commit(),
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordEditor extends StatelessWidget {
  const _PasswordEditor({required this.viewModel});

  final EncryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PasswordField(
          fieldKey: const ValueKey('encrypt-user-password'),
          value: viewModel.userPassword,
          labelText: l10n.toolsProtectUserPasswordLabel,
          helperText: l10n.toolsProtectUserPasswordHelper,
          onChanged: viewModel.onUserPasswordChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PasswordField(
          fieldKey: const ValueKey('encrypt-owner-password'),
          value: viewModel.ownerPassword,
          labelText: l10n.toolsProtectOwnerPasswordLabel,
          helperText: l10n.toolsProtectOwnerPasswordHelper,
          onChanged: viewModel.onOwnerPasswordChanged,
        ),
      ],
    );
  }
}

class _SecurityEditor extends StatelessWidget {
  const _SecurityEditor({required this.viewModel});

  final EncryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.toolsProtectEncryptionLabel),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<EncryptPdfEncryptionLevel>(
          key: const ValueKey('encrypt-level'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: EncryptPdfEncryptionLevel.aes256,
              icon: const Icon(Icons.enhanced_encryption_outlined, size: 18),
              label: Text(l10n.toolsProtectEncryptionAes256),
            ),
            ButtonSegment(
              value: EncryptPdfEncryptionLevel.aes128,
              icon: const Icon(Icons.lock_outline, size: 18),
              label: Text(l10n.toolsProtectEncryptionAes128),
            ),
            ButtonSegment(
              value: EncryptPdfEncryptionLevel.rc4,
              icon: const Icon(Icons.lock_open_outlined, size: 18),
              label: Text(l10n.toolsProtectEncryptionRc4),
            ),
          ],
          selected: {viewModel.level},
          onSelectionChanged: (selection) =>
              viewModel.onLevelChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsProtectEncryptionHelper),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.toolsProtectPermissionsLabel),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<EncryptPdfPermissionPreset>(
          key: const ValueKey('encrypt-permissions'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: EncryptPdfPermissionPreset.all,
              icon: const Icon(Icons.done_all_outlined, size: 18),
              label: Text(l10n.toolsProtectPermissionsAll),
            ),
            ButtonSegment(
              value: EncryptPdfPermissionPreset.readOnly,
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text(l10n.toolsProtectPermissionsReadOnly),
            ),
            ButtonSegment(
              value: EncryptPdfPermissionPreset.none,
              icon: const Icon(Icons.visibility_off_outlined, size: 18),
              label: Text(l10n.toolsProtectPermissionsNone),
            ),
          ],
          selected: {viewModel.permissions},
          onSelectionChanged: (selection) =>
              viewModel.onPermissionsChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsProtectPermissionsHelper),
      ],
    );
  }
}
