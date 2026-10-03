import 'package:material_ui/material_ui.dart';

import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

class ImageToPdfViewModel {
  const ImageToPdfViewModel({
    required this.inputs,
    required this.viewMode,
    required this.pageSize,
    required this.orientation,
    required this.fit,
    required this.outputFileName,
    required this.outputDirectory,
    required this.isSubmitting,
    required this.canConvert,
    required this.onAddImages,
    required this.onRemoveImage,
    required this.onReorder,
    required this.onViewModeChanged,
    required this.onPageSizeChanged,
    required this.onOrientationChanged,
    required this.onFitChanged,
    required this.onOutputFileNameChanged,
    required this.onChooseOutputFolder,
    required this.onConvert,
    required this.onBack,
  });

  final List<ImageToPdfToolInput> inputs;

  final ImagePickerViewMode viewMode;

  final ImageToPdfPageSize pageSize;
  final ImageToPdfOrientation orientation;
  final ImageToPdfFit fit;

  final String outputFileName;
  final String? outputDirectory;

  final bool isSubmitting;
  final bool canConvert;

  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImage;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<ImagePickerViewMode> onViewModeChanged;
  final ValueChanged<ImageToPdfPageSize> onPageSizeChanged;
  final ValueChanged<ImageToPdfOrientation> onOrientationChanged;
  final ValueChanged<ImageToPdfFit> onFitChanged;
  final ValueChanged<String> onOutputFileNameChanged;
  final VoidCallback onChooseOutputFolder;
  final VoidCallback onConvert;
  final VoidCallback onBack;
}
