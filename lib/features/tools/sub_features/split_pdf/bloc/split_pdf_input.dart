import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

/// User-facing model for the Split PDF tool.
class SplitPdfToolInput {
  const SplitPdfToolInput({
    required this.filePath,
    this.selections = const [],
    this.pageCount,
  });

  final String filePath;

  /// Page-selection groups; each group becomes its own output PDF.
  final List<String> selections;

  /// Number of pages per output PDF.
  final int? pageCount;

  SplitPdfToolInput copyWith({List<String>? selections, int? pageCount}) {
    return SplitPdfToolInput(
      filePath: filePath,
      selections: selections ?? this.selections,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  @override
  bool operator ==(covariant SplitPdfToolInput other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        listEquals(other.selections, selections) &&
        other.pageCount == pageCount;
  }

  @override
  int get hashCode =>
      filePath.hashCode ^ selections.hashCode ^ pageCount.hashCode;
}

extension SplitPdfMapper on SplitPdfToolInput {
  SplitPdfInput toSplitInput(SplitPdfMode mode) {
    switch (mode) {
      case SplitPdfMode.bySelection:
        if (selections.isEmpty) {
          throw const EmptyPageSelectionError();
        }

        return SplitPdfInput(
          file: File(filePath),
          mode: mode,
          selections: [
            for (final value in selections) PageSelectionParser().parse(value),
          ],
        );

      case SplitPdfMode.byPageCount:
        final count = pageCount;

        if (count == null || count <= 0) {
          throw ArgumentError('Page count must be greater than zero.');
        }

        return SplitPdfInput(
          file: File(filePath),
          mode: mode,
          pageCount: count,
        );

      case SplitPdfMode.extractAllPages:
        return SplitPdfInput(file: File(filePath), mode: mode);
    }
  }
}
