import 'merge_pdf_input.dart';

sealed class MergePdfState {
  const MergePdfState();
}

class MergePdfInitial extends MergePdfState {
  const MergePdfInitial();
}

class MergePdfReady extends MergePdfState {
  const MergePdfReady({
    this.inputs = const [],
    this.outputFileName = '',
    this.outputDirectory,
    this.isSubmitting = false,
  });

  final List<MergePdfToolInput> inputs;
  final String outputFileName;
  final String? outputDirectory;
  final bool isSubmitting;

  MergePdfReady copyWith({
    List<MergePdfToolInput>? inputs,
    String? outputFileName,
    String? outputDirectory,
    bool? isSubmitting,
  }) {
    return MergePdfReady(
      inputs: inputs ?? this.inputs,
      outputFileName: outputFileName ?? this.outputFileName,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class MergePdfError extends MergePdfState {
  const MergePdfError(this.error);

  final Object error;
}