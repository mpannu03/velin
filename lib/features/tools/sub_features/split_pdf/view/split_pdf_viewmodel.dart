import 'package:material_ui/material_ui.dart';

import 'package:velin/engine/engine.dart';

class SplitPdfViewModel {
  const SplitPdfViewModel({
    required this.inputFilePath,
    required this.mode,
    required this.selections,
    required this.pageCount,
    required this.outputDirectory,
    required this.isSubmitting,
    required this.canSplit,
    required this.onPickFile,
    required this.onModeChanged,
    required this.onPageCountChanged,
    required this.onAddSelection,
    required this.onSelectionChanged,
    required this.onRemoveSelection,
    required this.onChooseOutputFolder,
    required this.onSplit,
  });

  final String? inputFilePath;
  final SplitPdfMode mode;
  final List<String> selections;
  final String pageCount;
  final String? outputDirectory;

  final bool isSubmitting;
  final bool canSplit;

  final VoidCallback onPickFile;
  final ValueChanged<SplitPdfMode> onModeChanged;
  final ValueChanged<String> onPageCountChanged;
  final VoidCallback onAddSelection;
  final void Function(int index, String value) onSelectionChanged;
  final ValueChanged<int> onRemoveSelection;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onSplit;
}
