import 'rotate_pdf_input.dart';

class RotatePdfState {
  const RotatePdfState({
    this.inputFilePath,
    this.direction = RotatePdfDirection.clockwise90,
    this.scope = RotatePdfPageScope.allPages,
    this.selection = '',
    this.outputDirectory,
    this.outputFileName,
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final RotatePdfDirection direction;
  final RotatePdfPageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`.
  final String selection;

  final String? outputDirectory;
  final String? outputFileName;
  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  bool get hasValidSelection => selection.trim().isNotEmpty;

  bool get hasValidScopeConfig =>
      scope.requiresSelection ? hasValidSelection : true;

  bool get canRotate =>
      hasInputFile &&
      hasValidScopeConfig &&
      hasValidOutputDirectory &&
      hasValidOutputFileName &&
      !isSubmitting;

  RotatePdfState copyWith({
    Object? inputFilePath = _unset,
    RotatePdfDirection? direction,
    RotatePdfPageScope? scope,
    String? selection,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
    bool? isSubmitting,
  }) {
    return RotatePdfState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      direction: direction ?? this.direction,
      scope: scope ?? this.scope,
      selection: selection ?? this.selection,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();