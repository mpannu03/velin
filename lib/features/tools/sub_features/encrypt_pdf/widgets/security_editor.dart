import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Encryption level and permission presets for the output document.
class SecurityEditor extends StatelessWidget {
  const SecurityEditor({
    required this.level,
    required this.permissions,
    required this.onLevelChanged,
    required this.onPermissionsChanged,
    super.key,
  });

  final EncryptPdfEncryptionLevel level;
  final EncryptPdfPermissionPreset permissions;

  final ValueChanged<EncryptPdfEncryptionLevel> onLevelChanged;
  final ValueChanged<EncryptPdfPermissionPreset> onPermissionsChanged;

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
          selected: {level},
          onSelectionChanged: (selection) => onLevelChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsProtectEncryptionHelper),
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
          selected: {permissions},
          onSelectionChanged: (selection) =>
              onPermissionsChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsProtectPermissionsHelper),
      ],
    );
  }
}
