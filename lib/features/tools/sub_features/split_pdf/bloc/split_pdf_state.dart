import 'package:velin/engine/engine.dart';

class SplitPdfState {
  const SplitPdfState({
    this.inputFilePath,
    this.mode = SplitPdfMode.byPageCount,
    this.selections = const [],
    this.pageCount = '',
    this.outputDirectory,
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final SplitPdfMode mode;

  /// Page-selection groups; each group becomes its own output PDF.
  final List<String> selections;

  /// Raw text for the number of pages per output PDF.
  final String pageCount;

  final String? outputDirectory;
  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  int? get parsedPageCount => int.tryParse(pageCount.trim());

  bool get hasValidPageCount {
    final count = parsedPageCount;
    return count != null && count > 0;
  }

  bool get hasValidSelections =>
      selections.isNotEmpty && selections.every((s) => s.trim().isNotEmpty);

  bool get hasValidModeConfig => switch (mode) {
        SplitPdfMode.byPageCount => hasValidPageCount,
        SplitPdfMode.bySelection => hasValidSelections,
        SplitPdfMode.extractAllPages => true,
      };

  bool get canSplit =>
      hasInputFile &&
      hasValidModeConfig &&
      hasValidOutputDirectory &&
      !isSubmitting;

  SplitPdfState copyWith({
    Object? inputFilePath = _unset,
    SplitPdfMode? mode,
    List<String>? selections,
    String? pageCount,
    Object? outputDirectory = _unset,
    bool? isSubmitting,
  }) {
    return SplitPdfState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      mode: mode ?? this.mode,
      selections: selections ?? this.selections,
      pageCount: pageCount ?? this.pageCount,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();
