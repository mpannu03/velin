import 'merge_pdf_input.dart';

class MergePdfState {
  const MergePdfState({
    this.inputs = const [],
    this.outputFileName = 'merged.pdf',
    this.outputDirectory,
    this.isSubmitting = false,
  });

  final List<MergePdfToolInput> inputs;
  final String outputFileName;
  final String? outputDirectory;
  final bool isSubmitting;

  bool get hasInputFiles => inputs.isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName => outputFileName.trim().isNotEmpty;

  bool get canMerge =>
      hasInputFiles &&
      hasValidOutputFileName &&
      hasValidOutputDirectory &&
      !isSubmitting;

  MergePdfState copyWith({
    List<MergePdfToolInput>? inputs,
    String? outputFileName,
    Object? outputDirectory = _unset,
    bool? isSubmitting,
  }) {
    return MergePdfState(
      inputs: inputs ?? this.inputs,
      outputFileName: outputFileName ?? this.outputFileName,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();
