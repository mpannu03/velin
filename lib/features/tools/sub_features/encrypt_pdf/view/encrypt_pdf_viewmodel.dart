import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

class EncryptPdfViewModel {
  const EncryptPdfViewModel({
    required this.inputFilePath,
    required this.outputFileName,
    required this.outputDirectory,
    required this.userPassword,
    required this.ownerPassword,
    required this.level,
    required this.permissions,
    required this.isSubmitting,
    required this.canProtect,
    required this.onPickFile,
    required this.onUserPasswordChanged,
    required this.onOwnerPasswordChanged,
    required this.onLevelChanged,
    required this.onPermissionsChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onProtect,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? outputFileName;
  final String? outputDirectory;

  final String userPassword;
  final String ownerPassword;
  final EncryptPdfEncryptionLevel level;
  final EncryptPdfPermissionPreset permissions;

  final bool isSubmitting;
  final bool canProtect;

  final VoidCallback onPickFile;
  final ValueChanged<String> onUserPasswordChanged;
  final ValueChanged<String> onOwnerPasswordChanged;
  final ValueChanged<EncryptPdfEncryptionLevel> onLevelChanged;
  final ValueChanged<EncryptPdfPermissionPreset> onPermissionsChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onProtect;
  final VoidCallback onBack;
}
