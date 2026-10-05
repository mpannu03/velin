import 'package:material_ui/material_ui.dart';

class CompressPdfViewModel {
  const CompressPdfViewModel({
    required this.inputFilePath,
    required this.outputFileName,
    required this.outputDirectory,
    required this.quality,
    required this.isSubmitting,
    required this.canCompress,
    required this.onPickFile,
    required this.onQualityChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onCompress,
    required this.onBack,
  });

  final String? inputFilePath;
  final String? outputFileName;
  final String? outputDirectory;

  /// Compression effort from 0 to 100.
  final int quality;

  final bool isSubmitting;
  final bool canCompress;

  final VoidCallback onPickFile;
  final ValueChanged<int> onQualityChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onCompress;
  final VoidCallback onBack;
}
