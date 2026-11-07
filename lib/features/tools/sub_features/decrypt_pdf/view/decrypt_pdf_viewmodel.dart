import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';

class DecryptPdfViewModel {
  const DecryptPdfViewModel({
    required this.inputFilePath,
    required this.outputFileName,
    required this.outputDirectory,
    required this.password,
    required this.isSubmitting,
    this.task,
    required this.canDecrypt,
    required this.onPickFile,
    required this.onPasswordChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onUnlock,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? outputFileName;
  final String? outputDirectory;

  final String password;

  final bool isSubmitting;

  /// Progress and cancellation of the running task.

  final ToolTaskHandle? task;
  final bool canDecrypt;

  final VoidCallback onPickFile;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onUnlock;
  final VoidCallback onBack;
}
