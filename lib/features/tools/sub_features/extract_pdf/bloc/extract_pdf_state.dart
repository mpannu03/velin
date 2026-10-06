class ExtractPdfState {
  const ExtractPdfState({
    this.filePath,
    this.pageSelection,
    this.outputDirectory,
    this.outputFileName,
    this.isSubmitting = false,
  });

  final String? filePath;
  final String? pageSelection;
  final String? outputDirectory;
  final String? outputFileName;
  final bool isSubmitting;

  bool get hasValidInputFilePath => filePath != null && filePath!.isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  bool get canExtract =>
      hasValidInputFilePath &&
      hasValidOutputDirectory &&
      hasValidOutputFileName;

  ExtractPdfState copyWith({
    Object? filePath = _unset,
    Object? pageSelection = _unset,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
    bool? isSubmitting,
  }) {
    return ExtractPdfState(
      filePath: identical(filePath, _unset)
          ? this.filePath
          : filePath as String?,
      pageSelection: identical(pageSelection, _unset)
          ? this.pageSelection
          : pageSelection as String?,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  bool operator ==(covariant ExtractPdfState other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        other.pageSelection == pageSelection &&
        other.outputDirectory == outputDirectory &&
        other.outputFileName == outputFileName &&
        other.isSubmitting == isSubmitting;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        pageSelection.hashCode ^
        outputDirectory.hashCode ^
        outputFileName.hashCode ^
        isSubmitting.hashCode;
  }
}

const _unset = Object();
