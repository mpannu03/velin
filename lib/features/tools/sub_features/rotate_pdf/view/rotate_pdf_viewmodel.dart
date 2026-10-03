import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

class RotatePdfViewModel {
  const RotatePdfViewModel({
    required this.inputFilePath,
    required this.direction,
    required this.scope,
    required this.selection,
    required this.outputFileName,
    required this.outputDirectory,
    required this.isSubmitting,
    required this.canRotate,
    required this.onPickFile,
    required this.onDirectionChanged,
    required this.onScopeChanged,
    required this.onSelectionChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onRotate,
    required this.onBack,
  });

  final String? inputFilePath;
  final RotatePdfDirection direction;
  final RotatePdfPageScope scope;
  final String selection;
  final String? outputFileName;
  final String? outputDirectory;

  final bool isSubmitting;
  final bool canRotate;

  final VoidCallback onPickFile;
  final ValueChanged<RotatePdfDirection> onDirectionChanged;
  final ValueChanged<RotatePdfPageScope> onScopeChanged;
  final ValueChanged<String> onSelectionChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onRotate;
  final VoidCallback onBack;
}