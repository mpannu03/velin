import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';

class ExtractPdfViewModel {
  const ExtractPdfViewModel({
    required this.inputFilePath,
    required this.pageSelection,
    required this.outputFileName,
    required this.outputDirectory,
    required this.isSubmitting,
    this.task,
    required this.canExtract,
    required this.onPickFile,
    required this.onSelectionChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onExtract,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? pageSelection;
  final String? outputFileName;
  final String? outputDirectory;

  final bool isSubmitting;

  /// Progress and cancellation of the running task.

  final ToolTaskHandle? task;
  final bool canExtract;

  final VoidCallback onPickFile;
  final ValueChanged<String> onSelectionChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onExtract;
  final VoidCallback onBack;
}
