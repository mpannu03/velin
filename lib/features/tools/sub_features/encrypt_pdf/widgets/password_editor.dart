import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// The user and owner password fields. Both commit on submit and on focus loss.
class PasswordEditor extends StatelessWidget {
  const PasswordEditor({
    required this.userPassword,
    required this.ownerPassword,
    required this.onUserPasswordChanged,
    required this.onOwnerPasswordChanged,
    super.key,
  });

  final String userPassword;
  final String ownerPassword;

  final ValueChanged<String> onUserPasswordChanged;
  final ValueChanged<String> onOwnerPasswordChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordField(
          fieldKey: const ValueKey('encrypt-user-password'),
          value: userPassword,
          labelText: l10n.toolsProtectUserPasswordLabel,
          helperText: l10n.toolsProtectUserPasswordHelper,
          onChanged: onUserPasswordChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        PasswordField(
          fieldKey: const ValueKey('encrypt-owner-password'),
          value: ownerPassword,
          labelText: l10n.toolsProtectOwnerPasswordLabel,
          helperText: l10n.toolsProtectOwnerPasswordHelper,
          onChanged: onOwnerPasswordChanged,
        ),
      ],
    );
  }
}
