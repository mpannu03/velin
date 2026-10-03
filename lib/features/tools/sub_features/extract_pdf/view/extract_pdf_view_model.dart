import 'package:material_ui/material_ui.dart';

class ExtractPdfViewModel {
  const ExtractPdfViewModel({
    required this.inputFilePath,
    required this.pageSelection,
    required this.outputDirectory,
    required this.isSubmitting,
    required this.canExtract,
    required this.onPickFile,
    required this.onSelectionChanged,
    required this.onChooseOutputFolder,
    required this.onExtract,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? pageSelection;
  final String? outputDirectory;

  final bool isSubmitting;
  final bool canExtract;

  final VoidCallback onPickFile;
  final ValueChanged<String> onSelectionChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onExtract;
  final VoidCallback onBack;
}