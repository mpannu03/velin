import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

/// How the selected pages should be turned.
///
/// The names describe the visual result rather than the raw angle, because
/// `270` means "90 degrees counter-clockwise" to a user, not "270".
enum RotatePdfDirection {
  clockwise90(degrees: 90),
  upsideDown(degrees: 180),
  counterClockwise90(degrees: 270);

  const RotatePdfDirection({required this.degrees});

  /// Clockwise angle in degrees, as expected by [RotatePdfEngine].
  final int degrees;
}

/// Which pages take part in the rotation.
enum RotatePdfPageScope {
  allPages,
  selectedPages;

  bool get requiresSelection => this == RotatePdfPageScope.selectedPages;
}

/// User-facing model for the Rotate PDF tool.
class RotatePdfToolInput {
  const RotatePdfToolInput({
    required this.filePath,
    required this.direction,
    this.scope = RotatePdfPageScope.allPages,
    this.selection = '',
  });

  final String filePath;
  final RotatePdfDirection direction;
  final RotatePdfPageScope scope;

  /// Raw page-selection text, e.g. `1-5, 8, last`. Ignored when
  /// [scope] is [RotatePdfPageScope.allPages].
  final String selection;

  /// Parsed page selection, or `null` when the whole document is rotated.
  ///
  /// Throws [PageSelectionError] when [selection] is empty or malformed and
  /// [scope] is [RotatePdfPageScope.selectedPages].
  PageSelection? get parsedSelection {
    if (!scope.requiresSelection) {
      return null;
    }

    if (selection.trim().isEmpty) {
      throw const EmptyPageSelectionError();
    }

    return PageSelectionParser().parse(selection);
  }

  RotatePdfToolInput copyWith({
    RotatePdfDirection? direction,
    RotatePdfPageScope? scope,
    String? selection,
  }) {
    return RotatePdfToolInput(
      filePath: filePath,
      direction: direction ?? this.direction,
      scope: scope ?? this.scope,
      selection: selection ?? this.selection,
    );
  }
}