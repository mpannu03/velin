import 'package:material_ui/material_ui.dart';

import '../merge_pdf.dart';

class MergePdfViewModel {
  const MergePdfViewModel({
    required this.inputs,
    required this.outputFileName,
    required this.outputDirectory,
    required this.onAddFiles,
    required this.onRemoveFile,
    required this.onReorder,
    required this.onPageSelectionChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onMerge,
    required this.isSubmitting,
    required this.hasInputFiles,
    required this.canMerge,
  });

  final List<MergePdfToolInput> inputs;

  final String outputFileName;
  final String? outputDirectory;

  final VoidCallback onAddFiles;
  final ValueChanged<int> onRemoveFile;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index, String value) onPageSelectionChanged;

  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;

  final VoidCallback onMerge;

  final bool isSubmitting;
  final bool hasInputFiles;
  final bool canMerge;
}
